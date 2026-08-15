package hanga.mod

/** Host/mod bus values. Maps onto WIT `value` (JSON-shaped). */
sealed class Wire {
    data object Empty : Wire()
    data class Flag(val value: Boolean) : Wire()
    data class Int(val value: Long) : Wire()
    data class Float(val value: Double) : Wire()
    data class Text(val value: String) : Wire()
    data class Items(val items: List<Wire>) : Wire()
    data class Bag(val fields: List<Field>) : Wire()
    data class Fail(val reason: String) : Wire()

    fun asText(): String? = (this as? Text)?.value

    fun bagText(key: String): String? =
        (this as? Bag)?.fields?.firstOrNull { it.key == key }?.let { field ->
            (field.value as? Text)?.value
        }

    fun bagFlag(key: String): Boolean =
        (this as? Bag)?.fields?.any { field ->
            field.key == key &&
                when (val child = field.value) {
                    is Flag -> child.value
                    is Int -> child.value == 1L
                    else -> false
                }
        } == true

    fun bagInt(key: String): Long =
        (this as? Bag)?.fields?.firstOrNull { it.key == key }?.let { field ->
            when (val child = field.value) {
                is Int -> child.value
                is Text -> child.value.toLongOrNull()
                else -> null
            }
        } ?: 0L

    companion object {
        fun text(value: String): Wire = Text(value)

        fun voxelProbe(name: String, edit: Boolean): Wire =
            Bag(
                listOf(
                    Field("name", Text(name)),
                    Field("edit", Flag(edit)),
                ),
            )
    }
}

data class Field(val key: String, val value: Wire)
