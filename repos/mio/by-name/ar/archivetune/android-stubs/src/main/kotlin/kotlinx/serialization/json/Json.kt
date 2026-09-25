package kotlinx.serialization.json
open class Json {
    companion object {
    }
}
open class JsonBuilder {
    var ignoreUnknownKeys: Boolean = false
}
fun Json(block: JsonBuilder.() -> Unit): Json = Json()
inline fun <reified T> Json.decodeFromString(string: String): T = TODO()
