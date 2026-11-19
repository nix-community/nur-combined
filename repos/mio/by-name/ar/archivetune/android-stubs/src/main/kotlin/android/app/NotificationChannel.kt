package android.app
open class NotificationChannel(
    val id: String,
    val name: CharSequence,
    val importance: Int,
) {
    var description: String = ""
}
