package io.snippeter.jetbrains.actions

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.progress.ProgressIndicator
import com.intellij.openapi.progress.ProgressManager
import com.intellij.openapi.progress.Task
import com.intellij.openapi.project.Project
import io.snippeter.jetbrains.Notifications
import io.snippeter.jetbrains.SnippeterClient
import io.snippeter.jetbrains.SnippeterException
import io.snippeter.jetbrains.ui.SignInDialog

/**
 * Tools > Snippeter > Sign In.
 *
 * Shows the credential dialog, runs the GoTrue password grant off the EDT, and
 * reports success/failure with a balloon. Tokens land in PasswordSafe.
 */
class SignInAction : AnAction() {

    override fun actionPerformed(e: AnActionEvent) {
        val project = e.project
        val dialog = SignInDialog(project)
        if (!dialog.showAndGet()) {
            return
        }

        val email = dialog.email
        val password = dialog.password

        ProgressManager.getInstance().run(
            object : Task.Backgroundable(project, "Signing in to Snippeter", true) {
                override fun run(indicator: ProgressIndicator) {
                    indicator.isIndeterminate = true
                    try {
                        SnippeterClient.signIn(email, password)
                        notifyInfo(project, "Signed in to Snippeter as $email.")
                    } catch (ex: SnippeterException) {
                        notifyError(project, ex.message ?: "Sign-in failed.")
                    } catch (ex: Exception) {
                        notifyError(project, "Could not reach Snippeter: ${ex.message}")
                    }
                }
            },
        )
    }

    private fun notifyInfo(project: Project?, message: String) {
        ApplicationManager.getApplication().invokeLater {
            Notifications.info(project, message)
        }
    }

    private fun notifyError(project: Project?, message: String) {
        ApplicationManager.getApplication().invokeLater {
            Notifications.error(project, message)
        }
    }
}
