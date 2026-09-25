package kotlinx.serialization.json

open class JsonBuilder {
    var ignoreUnknownKeys: Boolean = false
    var encodeDefaults: Boolean = false
    var explicitNulls: Boolean = false
}

open class Json {
    companion object {
        var ignoreUnknownKeys: Boolean = false
        var encodeDefaults: Boolean = false
        var explicitNulls: Boolean = false
    }
    
    inline fun <reified T> decodeFromString(string: String): T = TODO()
    fun <T> decodeFromString(deserializer: Any, string: String): T = TODO()
}

fun Json(block: JsonBuilder.() -> Unit): Json = Json()
