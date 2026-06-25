package io.snippeter.jetbrains.ui

import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.DialogWrapper
import com.intellij.openapi.ui.ValidationInfo
import com.intellij.ui.components.JBLabel
import com.intellij.ui.components.JBPasswordField
import com.intellij.ui.components.JBTextField
import com.intellij.util.ui.FormBuilder
import com.intellij.util.ui.JBUI
import javax.swing.JComponent
import javax.swing.JPanel

/**
 * Collects an email + password for the GoTrue password grant.
 *
 * The dialog only validates that both fields are non-empty and the email looks
 * plausible; the actual credential check happens on submit against the backend.
 */
class SignInDialog(project: Project?) : DialogWrapper(project) {

    private val emailField = JBTextField(28)
    private val passwordField = JBPasswordField()

    val email: String get() = emailField.text.trim()
    val password: String get() = String(passwordField.password)

    init {
        title = "Sign In to Snippeter"
        setOKButtonText("Sign In")
        init()
    }

    override fun createCenterPanel(): JComponent {
        val intro = JBLabel("Sign in with your Snippeter email and password.")
        intro.border = JBUI.Borders.emptyBottom(8)

        val form: JPanel = FormBuilder.createFormBuilder()
            .addComponent(intro)
            .addLabeledComponent("Email:", emailField)
            .addLabeledComponent("Password:", passwordField)
            .panel
        form.border = JBUI.Borders.empty(8)
        return form
    }

    override fun getPreferredFocusedComponent(): JComponent = emailField

    override fun doValidate(): ValidationInfo? {
        val mail = email
        if (mail.isEmpty()) {
            return ValidationInfo("Enter your email address.", emailField)
        }
        if (!mail.contains("@") || !mail.contains(".")) {
            return ValidationInfo("Enter a valid email address.", emailField)
        }
        if (password.isEmpty()) {
            return ValidationInfo("Enter your password.", passwordField)
        }
        return null
    }
}
