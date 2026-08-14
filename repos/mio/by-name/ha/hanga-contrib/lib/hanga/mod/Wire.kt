package hanga.mod

/** Host/mod bus values. Maps onto WIT `payload` / `atom` / `field`. */
sealed class Atom {
    data class Flag(val value: Boolean) : Atom()
    data class Int(val value: Long) : Atom()
    data class Float(val value: Double) : Atom()
    data class Text(val value: String) : Atom()
}

data class Field(val key: String, val value: Atom)

sealed class Wire {
    data object Empty : Wire()
    data class Flag(val value: Boolean) : Wire()
    data class Int(val value: Long) : Wire()
    data class Float(val value: Double) : Wire()
    data class Text(val value: String) : Wire()
    data class Bag(val fields: List<Field>) : Wire()

    fun asText(): String? = (this as? Text)?.value

    fun bagText(key: String): String? =
        (this as? Bag)?.fields?.firstOrNull { it.key == key }?.let { field ->
            when (val atom = field.value) {
                is Atom.Text -> atom.value
                else -> null
            }
        }

    fun bagFlag(key: String): Boolean =
        (this as? Bag)?.fields?.any { field ->
            field.key == key &&
                when (val atom = field.value) {
                    is Atom.Flag -> atom.value
                    is Atom.Int -> atom.value == 1L
                    else -> false
                }
        } == true

    fun bagInt(key: String): Long =
        (this as? Bag)?.fields?.firstOrNull { it.key == key }?.let { field ->
            when (val atom = field.value) {
                is Atom.Int -> atom.value
                is Atom.Text -> atom.value.toLongOrNull()
                else -> null
            }
        } ?: 0L

    companion object {
        fun text(value: String): Wire = Text(value)

        fun voxelProbe(name: String, edit: Boolean): Wire =
            Bag(
                listOf(
                    Field("name", Atom.Text(name)),
                    Field("edit", Atom.Flag(edit)),
                ),
            )
    }
}
