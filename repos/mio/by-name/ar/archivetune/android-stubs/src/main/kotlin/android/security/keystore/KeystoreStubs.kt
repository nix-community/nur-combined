package android.security.keystore

import java.security.spec.AlgorithmParameterSpec

/** Desktop stub: :modules only constructs this to configure a platform key. */
class KeyGenParameterSpec private constructor() : AlgorithmParameterSpec {
    class Builder(alias: String, purposes: Int) {
        fun setBlockModes(vararg blockModes: String): Builder = this
        fun setEncryptionPaddings(vararg paddings: String): Builder = this
        fun setUserAuthenticationRequired(required: Boolean): Builder = this
        fun build(): KeyGenParameterSpec = KeyGenParameterSpec()
    }
}

object KeyProperties {
    const val PURPOSE_ENCRYPT = 1
    const val PURPOSE_DECRYPT = 2
    const val KEY_ALGORITHM_AES = "AES"
    const val BLOCK_MODE_GCM = "GCM"
    const val ENCRYPTION_PADDING_NONE = "NoPadding"
}
