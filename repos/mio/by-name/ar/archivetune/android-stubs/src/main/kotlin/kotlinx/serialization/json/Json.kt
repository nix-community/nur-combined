package kotlinx.serialization.json

import kotlinx.serialization.KSerializer
import kotlinx.serialization.DeserializationStrategy
import kotlinx.serialization.SerializationStrategy

class Json(val configuration: JsonConfiguration = JsonConfiguration()) {
    fun <T> encodeToString(serializer: SerializationStrategy<T>, value: T): String = ""
    fun <T> decodeFromString(deserializer: DeserializationStrategy<T>, string: String): T = TODO()
    
    companion object Default : Json() {
        inline fun <reified T> encodeToString(value: T): String = ""
        inline fun <reified T> decodeFromString(string: String): T = TODO()
    }
}

class JsonConfiguration

fun Json(from: Json = Json, builderAction: JsonBuilder.() -> Unit): Json = Json()

class JsonBuilder {
    var prettyPrint: Boolean = false
    var ignoreUnknownKeys: Boolean = false
    var isLenient: Boolean = false
    var encodeDefaults: Boolean = false
    var explicitNulls: Boolean = true
    var coerceInputValues: Boolean = false
    var useArrayPolymorphism: Boolean = false
    var classDiscriminator: String = "type"
    var allowSpecialFloatingPointValues: Boolean = false
    var allowStructuredMapKeys: Boolean = false
    var useAlternativeNames: Boolean = true
    var namingStrategy: Any? = null
}

inline fun <reified T> Json.encodeToString(value: T): String = ""
inline fun <reified T> Json.decodeFromString(string: String): T = TODO()
