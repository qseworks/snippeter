package io.snippeter.jetbrains.actions

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.actionSystem.CommonDataKeys
import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.fileEditor.FileDocumentManager
import com.intellij.openapi.progress.ProgressIndicator
import com.intellij.openapi.progress.ProgressManager
import com.intellij.openapi.progress.Task
import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.Messages
import io.snippeter.jetbrains.Notifications
import io.snippeter.jetbrains.SessionStore
import io.snippeter.jetbrains.SnippeterClient
import io.snippeter.jetbrains.SnippeterException

/**
 * Tools > Snippeter > Save Selection as Snippet.
 *
 * Uses the editor selection, or the whole document when nothing is selected.
 * Prompts for a title (defaulting to the file name) and POSTs a snippet plus its
 * single mirrored file, then reports the result with a balloon.
 */
class SaveSelectionAction : AnAction() {

    override fun update(e: AnActionEvent) {
        e.presentation.isEnabled = e.getData(CommonDataKeys.EDITOR) != null
    }

    override fun actionPerformed(e: AnActionEvent) {
        val project = e.project
        val editor = e.getData(CommonDataKeys.EDITOR)
        if (editor == null) {
            Notifications.error(project, "Open a file in the editor to save a snippet.")
            return
        }

        if (!SessionStore.isSignedIn()) {
            Notifications.error(project, "You are not signed in. Run \"Snippeter: Sign In\" first.")
            return
        }

        val selectionModel = editor.selectionModel
        val content = if (selectionModel.hasSelection()) {
            selectionModel.selectedText ?: ""
        } else {
            editor.document.text
        }

        if (content.isBlank()) {
            Notifications.error(project, "Nothing to save — the selection and document are empty.")
            return
        }

        val virtualFile = FileDocumentManager.getInstance().getFile(editor.document)
        val defaultTitle = virtualFile?.name ?: "Untitled snippet"
        val languageId = languageIdFor(virtualFile?.extension)

        val title = Messages.showInputDialog(
            project,
            "Title for this snippet:",
            "Save Selection as Snippet",
            Messages.getQuestionIcon(),
            defaultTitle,
            null,
        ) ?: return // user cancelled

        val finalTitle = title.trim().ifBlank { defaultTitle }

        ProgressManager.getInstance().run(
            object : Task.Backgroundable(project, "Saving snippet", true) {
                override fun run(indicator: ProgressIndicator) {
                    indicator.isIndeterminate = true
                    try {
                        SnippeterClient.saveSnippet(finalTitle, content, languageId)
                        notifyInfo(project, "Saved \"$finalTitle\" to Snippeter.")
                    } catch (ex: SnippeterException) {
                        notifyError(project, ex.message ?: "Could not save the snippet.")
                    } catch (ex: Exception) {
                        notifyError(project, "Could not reach Snippeter: ${ex.message}")
                    }
                }
            },
        )
    }

    /** Maps a file extension to the backend's language_id vocabulary. */
    private fun languageIdFor(extension: String?): String = when (extension?.lowercase()) {
        "kt", "kts" -> "kotlin"
        "java" -> "java"
        "js", "mjs", "cjs" -> "javascript"
        "ts" -> "typescript"
        "tsx" -> "typescriptreact"
        "jsx" -> "javascriptreact"
        "py" -> "python"
        "rb" -> "ruby"
        "go" -> "go"
        "rs" -> "rust"
        "dart" -> "dart"
        "swift" -> "swift"
        "cs" -> "csharp"
        "cpp", "cc", "cxx", "hpp" -> "cpp"
        "c", "h" -> "c"
        "php" -> "php"
        "html", "htm" -> "html"
        "css" -> "css"
        "scss" -> "scss"
        "json" -> "json"
        "yaml", "yml" -> "yaml"
        "md", "markdown" -> "markdown"
        "sql" -> "sql"
        "sh", "bash", "zsh" -> "shell"
        "xml" -> "xml"
        else -> "plaintext"
    }

    private fun notifyInfo(project: Project?, message: String) {
        ApplicationManager.getApplication().invokeLater { Notifications.info(project, message) }
    }

    private fun notifyError(project: Project?, message: String) {
        ApplicationManager.getApplication().invokeLater { Notifications.error(project, message) }
    }
}
