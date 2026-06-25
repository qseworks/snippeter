package io.snippeter.jetbrains

import com.intellij.credentialStore.CredentialAttributes
import com.intellij.credentialStore.Credentials
import com.intellij.credentialStore.generateServiceName
import com.intellij.ide.passwordSafe.PasswordSafe

/**
 * Persists the GoTrue session (access + refresh tokens) in the IDE's PasswordSafe.
 *
 * Two credential entries are kept under the "Snippeter" service so that tokens
 * are stored using the user's configured secure storage (Keychain / KWallet /
 * encrypted file) rather than plain settings.
 */
object SessionStore {

    private const val SUBSYSTEM = "Snippeter"
    private const val KEY_ACCESS = "access_token"
    private const val KEY_REFRESH = "refresh_token"

    private fun attributes(key: String): CredentialAttributes =
        CredentialAttributes(generateServiceName(SUBSYSTEM, key))

    /** Stores both tokens; passing null clears the corresponding entry. */
    fun save(accessToken: String?, refreshToken: String?) {
        val safe = PasswordSafe.instance
        safe.set(
            attributes(KEY_ACCESS),
            if (accessToken.isNullOrBlank()) null else Credentials(SUBSYSTEM, accessToken),
        )
        safe.set(
            attributes(KEY_REFRESH),
            if (refreshToken.isNullOrBlank()) null else Credentials(SUBSYSTEM, refreshToken),
        )
    }

    fun accessToken(): String? =
        PasswordSafe.instance.get(attributes(KEY_ACCESS))?.getPasswordAsString()?.takeIf { it.isNotBlank() }

    fun refreshToken(): String? =
        PasswordSafe.instance.get(attributes(KEY_REFRESH))?.getPasswordAsString()?.takeIf { it.isNotBlank() }

    fun isSignedIn(): Boolean = accessToken() != null

    fun clear() {
        save(null, null)
    }
}
