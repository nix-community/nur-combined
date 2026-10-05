package kotlinx.serialization.json

class JsonBuilder {
    var ignoreUnknownKeys: Boolean = false
    var prettyPrint: Boolean = false
    var encodeDefaults: Boolean = false
    var isLenient: Boolean = false
}

class Json(builderAction: JsonBuilder.() -> Unit = {}) {
    fun parseToJsonElement(string: String): JsonElement = JsonObject(emptyMap())
}

abstract class JsonElement {
    val jsonArray: JsonArray get() = JsonArray(emptyList())
    val jsonPrimitive: JsonPrimitive get() = JsonPrimitive("")
    val jsonObject: JsonObject get() = JsonObject(emptyMap())
}

class JsonArray(private val elements: List<JsonElement>) : JsonElement(), List<JsonElement> by elements

class JsonObject(private val content: Map<String, JsonElement>) : JsonElement(), Map<String, JsonElement> by content {
    override fun toString(): String {
        return content.entries.joinToString(
            separator = ",",
            prefix = "{",
            postfix = "}"
        ) { "\"${it.key}\":${it.value}" }
    }
}

class JsonPrimitive(private val value: String) : JsonElement() {
    val isString: Boolean = true
    val content: String = value
    val long: Long = 0L
    override fun toString(): String = "\"$value\""
}

object JsonNull : JsonElement() {
    override fun toString(): String = "null"
}

val JsonElement.jsonPrimitive: JsonPrimitive get() = this as JsonPrimitive
val JsonElement.jsonArray: JsonArray get() = this as JsonArray
val JsonElement.jsonObject: JsonObject get() = this as JsonObject
val JsonPrimitive.long: Long get() = 0L
