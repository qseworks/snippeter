package io.snippeter.jetbrains.actions

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.actionSystem.CommonDataKeys
import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.command.WriteCommandAction
import com.intellij.openapi.editor.Editor
import com.intellij.openapi.progress.ProgressIndicator
import com.intellij.openapi.progress.ProgressManager
import com.intellij.openapi.progress.Task
import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.popup.JBPopupFactory
import com.intellij.openapi.ui.popup.PopupStep
import com.intellij.openapi.ui.popup.util.BaseListPopupStep
import io.snippeter.jetbrains.Notifications
import io.snippeter.jetbrains.SessionStore
import io.snippeter.jetbrains.Snippet
import io.snippeter.jetbrains.SnippetFile
import io.snippeter.jetbrains.SnippeterClient
import io.snippeter.jetbrains.SnippeterException

/**
 * Tools > Snippeter > Insert Snippet.
 *
 * Requires an open editor. Fetches snippets, shows a chooser, resolves the file
 * to insert (single file → use it, many → second chooser, none → snippets.body),
 * then inserts the content at the caret inside a WriteCommandAction.
 */
class InsertSnippetAction : AnAction() {

    override fun update(e: AnActionEvent) {
        // Only enable when there is an editor to insert into.
        e.presentation.isEnabled = e.getData(CommonDataKeys.EDITOR) != null
    }

    override fun actionPerformed(e: AnActionEvent) {
        val project = e.project
        val editor = e.getData(CommonDataKeys.EDITOR)
        if (editor == null) {
            Notifications.error(project, "Open a file in the editor before inserting a snippet.")
            return
        }

        // Keep the fast path off the network when not authenticated.
        if (!SessionStore.isSignedIn()) {
            Notifications.error(project, "You are not signed in. Run \"Snippeter: Sign In\" first.")
            return
        }

        ProgressManager.getInstance().run(
            object : Task.Backgroundable(project, "Loading snippets", true) {
                override fun run(indicator: ProgressIndicator) {
                    indicator.isIndeterminate = true
                    try {
                        val snippets = SnippeterClient.fetchSnippets()
                        if (snippets.isEmpty()) {
                            notifyError(project, "You have no snippets yet. Save one first.")
                            return
                        }
                        onUi { chooseSnippet(project, editor, snippets) }
                    } catch (ex: SnippeterException) {
                        notifyError(project, ex.message ?: "Could not load snippets.")
                    } catch (ex: Exception) {
                        notifyError(project, "Could not reach Snippeter: ${ex.message}")
                    }
                }
            },
        )
    }

    private fun chooseSnippet(project: Project?, editor: Editor, snippets: List<Snippet>) {
        val step = object : BaseListPopupStep<Snippet>("Insert Snippet", snippets) {
            override fun getTextFor(value: Snippet): String {
                val lang = value.languageId.takeIf { it.isNotBlank() }
                return if (lang != null) "${value.title}  ·  $lang" else value.title
            }

            override fun onChosen(selectedValue: Snippet, finalChoice: Boolean): PopupStep<*>? {
                doFinalRunnable = Runnable { resolveAndInsert(project, editor, selectedValue) }
                return FINAL_CHOICE
            }
        }
        JBPopupFactory.getInstance().createListPopup(step).showInBestPositionFor(editor)
    }

    private fun resolveAndInsert(project: Project?, editor: Editor, snippet: Snippet) {
        ProgressManager.getInstance().run(
            object : Task.Backgroundable(project, "Loading snippet files", true) {
                override fun run(indicator: ProgressIndicator) {
                    indicator.isIndeterminate = true
                    try {
                        val files = SnippeterClient.fetchFiles(snippet.id)
                        when {
                            files.isEmpty() -> {
                                if (snippet.body.isEmpty()) {
                                    notifyError(project, "This snippet has no content.")
                                } else {
                                    onUi { insertText(project, editor, snippet.body) }
                                }
                            }
                            files.size == 1 -> onUi { insertText(project, editor, files[0].content) }
                            else -> onUi { chooseFile(project, editor, files) }
                        }
                    } catch (ex: SnippeterException) {
                        notifyError(project, ex.message ?: "Could not load snippet files.")
                    } catch (ex: Exception) {
                        notifyError(project, "Could not reach Snippeter: ${ex.message}")
                    }
                }
            },
        )
    }

    private fun chooseFile(project: Project?, editor: Editor, files: List<SnippetFile>) {
        val step = object : BaseListPopupStep<SnippetFile>("Choose File", files) {
            override fun getTextFor(value: SnippetFile): String {
                val lang = value.languageId.takeIf { it.isNotBlank() }
                return if (lang != null) "${value.filename}  ·  $lang" else value.filename
            }

            override fun onChosen(selectedValue: SnippetFile, finalChoice: Boolean): PopupStep<*>? {
                doFinalRunnable = Runnable { insertText(project, editor, selectedValue.content) }
                return FINAL_CHOICE
            }
        }
        JBPopupFactory.getInstance().createListPopup(step).showInBestPositionFor(editor)
    }

    private fun insertText(project: Project?, editor: Editor, text: String) {
        val document = editor.document
        WriteCommandAction.runWriteCommandAction(project, "Insert Snippet", null, {
            val caret = editor.caretModel.currentCaret
            val selectionModel = editor.selectionModel
            if (selectionModel.hasSelection()) {
                val start = selectionModel.selectionStart
                val end = selectionModel.selectionEnd
                document.replaceString(start, end, text)
                caret.moveToOffset(start + text.length)
                selectionModel.removeSelection()
            } else {
                val offset = caret.offset
                document.insertString(offset, text)
                caret.moveToOffset(offset + text.length)
            }
        })
    }

    private fun onUi(block: () -> Unit) {
        ApplicationManager.getApplication().invokeLater(block)
    }

    private fun notifyError(project: Project?, message: String) {
        onUi { Notifications.error(project, message) }
    }
}
