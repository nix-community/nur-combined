package android.text.method

interface MovementMethod

open class LinkMovementMethod : MovementMethod {
    companion object {
        private val instance = LinkMovementMethod()
        @JvmStatic
        fun getInstance(): MovementMethod = instance
    }
}
