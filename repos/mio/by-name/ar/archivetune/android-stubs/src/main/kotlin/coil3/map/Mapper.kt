package coil3.map

/*
 * Coil's Mapper is generic: upstream writes `Mapper<String, Any> { data, _ -> ... }`, so it needs
 * type parameters and a constructor taking the transform lambda.
 */
class Mapper<in T, out R>(
    val transform: (T, Any?) -> R?,
) {
    fun map(data: T, options: Any? = null): R? = transform(data, options)
}
