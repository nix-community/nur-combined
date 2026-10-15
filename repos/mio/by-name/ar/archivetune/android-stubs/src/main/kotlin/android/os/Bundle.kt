package android.os

open class Bundle {
    private val map = mutableMapOf<String, Any?>()

    open fun getString(key: String): String? = map[key] as? String
    open fun getString(key: String, defaultValue: String): String = (map[key] as? String) ?: defaultValue
    open fun getInt(key: String, defaultValue: Int = 0): Int = (map[key] as? Int) ?: defaultValue
    open fun getBoolean(key: String, defaultValue: Boolean = false): Boolean = (map[key] as? Boolean) ?: defaultValue
    open fun getLong(key: String, defaultValue: Long = 0L): Long = (map[key] as? Long) ?: defaultValue
    open fun putString(key: String, value: String?) { map[key] = value }
    open fun putInt(key: String, value: Int) { map[key] = value }
    open fun putBoolean(key: String, value: Boolean) { map[key] = value }
    open fun putLong(key: String, value: Long) { map[key] = value }
    open fun containsKey(key: String): Boolean = map.containsKey(key)

    open fun putParcelable(key: String, value: Any?) { map[key] = value }

    open fun getParcelable(key: String): Any? = map[key]

    @Suppress("UNCHECKED_CAST")
    open fun putStringArrayList(key: String, value: ArrayList<String>?) { map[key] = value }

    @Suppress("UNCHECKED_CAST")
    open fun getStringArrayList(key: String): ArrayList<String>? = map[key] as? ArrayList<String>

    open fun putAll(other: Bundle) { map.putAll(other.map) }

    open fun keySet(): Set<String> = map.keys

    companion object {
        val EMPTY: Bundle = Bundle()
    }
}
