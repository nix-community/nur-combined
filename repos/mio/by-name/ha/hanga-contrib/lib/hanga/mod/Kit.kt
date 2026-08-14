package hanga.mod

/** `key=value` records separated by `;` or newlines. Unknown keys are ignored. */
object Kit {
    fun fields(text: String): List<Pair<String, String>> =
        text.split(';', '\n').mapNotNull { raw ->
            val rec = raw.trim()
            if (rec.isEmpty() || rec.startsWith('#')) {
                null
            } else {
                val split = rec.split('=', limit = 2)
                if (split.size == 2) split[0].trim() to split[1].trim() else null
            }
        }

    fun get(text: String, key: String): String? =
        fields(text).firstOrNull { it.first == key }?.second

    fun flag(value: String): Boolean =
        when (value.trim().lowercase()) {
            "1", "true", "yes", "on" -> true
            else -> false
        }

    fun f32(text: String, key: String, default: Float): Float =
        get(text, key)?.toFloatOrNull() ?: default

    fun bool(text: String, key: String): Boolean =
        flag(get(text, key) ?: "0")
}
