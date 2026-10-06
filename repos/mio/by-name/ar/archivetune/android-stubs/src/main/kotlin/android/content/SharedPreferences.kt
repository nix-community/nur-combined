package android.content

/*
 * SharedPreferences was not stubbed at all, and Context.getSharedPreferences returned Any,
 * so every `.edit().putString(...).apply()` chain in the port failed. Modelled faithfully
 * enough for those chains to type-check.
 */
interface SharedPreferences {
    fun getString(key: String, defValue: String?): String?

    fun getStringSet(key: String, defValues: Set<String>?): Set<String>?

    fun getInt(key: String, defValue: Int): Int

    fun getLong(key: String, defValue: Long): Long

    fun getFloat(key: String, defValue: Float): Float

    fun getBoolean(key: String, defValue: Boolean): Boolean

    fun contains(key: String): Boolean

    fun edit(): Editor

    fun getAll(): MutableMap<String, Any?>

    fun registerOnSharedPreferenceChangeListener(listener: Any)

    fun unregisterOnSharedPreferenceChangeListener(listener: Any)

    operator fun get(key: String, defValue: Any?): Any? = null

    operator fun set(key: String, value: Any?) {}

    operator fun set(key: String, value: String?) {}

    operator fun set(key: String, value: Int) {}

    operator fun set(key: String, value: Boolean) {}

    operator fun set(key: String, value: Long) {}

    fun remove(key: String) {}

    fun clear() {}

    interface Editor {
        fun putString(key: String, value: String?): Editor

        fun putStringSet(key: String, values: Set<String>?): Editor

        fun putInt(key: String, value: Int): Editor

        fun putLong(key: String, value: Long): Editor

        fun putFloat(key: String, value: Float): Editor

        fun putBoolean(key: String, value: Boolean): Editor

        fun remove(key: String): Editor

        fun clear(): Editor

        fun commit(): Boolean

        fun apply()
    }
}

/** Inert [SharedPreferences.Editor] backing `Context.getSharedPreferences`. */
object NoopEditor : SharedPreferences.Editor {
    override fun putString(key: String, value: String?): SharedPreferences.Editor = this

    override fun putStringSet(key: String, values: Set<String>?): SharedPreferences.Editor = this

    override fun putInt(key: String, value: Int): SharedPreferences.Editor = this

    override fun putLong(key: String, value: Long): SharedPreferences.Editor = this

    override fun putFloat(key: String, value: Float): SharedPreferences.Editor = this

    override fun putBoolean(key: String, value: Boolean): SharedPreferences.Editor = this

    override fun remove(key: String): SharedPreferences.Editor = this

    override fun clear(): SharedPreferences.Editor = this

    override fun commit(): Boolean = true

    override fun apply() {}
}
