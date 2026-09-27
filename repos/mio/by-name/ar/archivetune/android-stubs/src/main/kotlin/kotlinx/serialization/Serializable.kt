package kotlinx.serialization

@Target(AnnotationTarget.CLASS)
annotation class Serializable

@Target(AnnotationTarget.PROPERTY)
annotation class SerialName(val value: String = "")

@Target(AnnotationTarget.PROPERTY)
annotation class Transient

interface KSerializer<T>

interface SerializationStrategy<in T>
interface DeserializationStrategy<out T>

inline fun <reified T> serializer(): KSerializer<T> = TODO()
