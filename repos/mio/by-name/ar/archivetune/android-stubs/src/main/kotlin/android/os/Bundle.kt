package android.os

open class Bundle {
    open fun getString(key: String): String? = null
    open fun getString(key: String, defaultValue: String): String = defaultValue
    open fun getInt(key: String, defaultValue: Int = 0): Int = defaultValue
    open fun getBoolean(key: String, defaultValue: Boolean = false): Boolean = defaultValue
    open fun getLong(key: String, defaultValue: Long = 0L): Long = defaultValue
    open fun putString(key: String, value: String?) {}
    open fun putInt(key: String, value: Int) {}
    open fun putBoolean(key: String, value: Boolean) {}
    open fun putLong(key: String, value: Long) {}
    open fun containsKey(key: String): Boolean = false
}
