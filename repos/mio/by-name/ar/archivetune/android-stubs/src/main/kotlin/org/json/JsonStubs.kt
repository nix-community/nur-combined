package org.json

class JSONException(message: String?, cause: Throwable? = null) : Exception(message, cause)

class JSONObject {
    private val map = LinkedHashMap<String, Any?>()

    constructor()
    constructor(json: String) {
        try {
            val trimmed = json.trim()
            if (trimmed.startsWith("{") && trimmed.endsWith("}")) {
                val body = trimmed.substring(1, trimmed.length - 1).trim()
                if (body.isNotEmpty()) {
                    val regex = """"([^"]+)"\s*:\s*("(?:\\.|[^"\\])*"|true|false|null|-?\d+(?:\.\d+)?|\[[^\]]*\]|\{[^}]*\})""".toRegex()
                    for (match in regex.findAll(body)) {
                        val key = match.groupValues[1]
                        val rawVal = match.groupValues[2]
                        map[key] = when {
                            rawVal == "true" -> true
                            rawVal == "false" -> false
                            rawVal == "null" -> null
                            rawVal.startsWith("\"") -> rawVal.substring(1, rawVal.length - 1)
                            rawVal.startsWith("[") -> JSONArray(rawVal)
                            rawVal.startsWith("{") -> JSONObject(rawVal)
                            rawVal.contains(".") -> rawVal.toDoubleOrNull() ?: rawVal
                            else -> rawVal.toLongOrNull() ?: rawVal.toIntOrNull() ?: rawVal
                        }
                    }
                }
            }
        } catch (_: Exception) {}
    }

    companion object {
        @JvmField
        val NULL: Any = Any()
    }

    fun put(name: String, value: Any?): JSONObject {
        map[name] = value
        return this
    }

    fun get(name: String): Any = map[name] ?: throw JSONException("No value for $name")
    fun opt(name: String): Any? = if (map[name] === NULL) null else map[name]
    fun isNull(name: String): Boolean = !has(name) || map[name] == null || map[name] === NULL

    fun getString(name: String): String = map[name]?.toString() ?: throw JSONException("No value for $name")
    fun optString(name: String): String = map[name]?.toString() ?: ""
    fun optString(name: String, fallback: String): String = map[name]?.toString() ?: fallback

    fun getInt(name: String): Int = (map[name] as? Number)?.toInt() ?: map[name]?.toString()?.toIntOrNull() ?: throw JSONException("Not an int: $name")
    fun optInt(name: String): Int = optInt(name, 0)
    fun optInt(name: String, fallback: Int): Int = (map[name] as? Number)?.toInt() ?: map[name]?.toString()?.toIntOrNull() ?: fallback

    fun getLong(name: String): Long = (map[name] as? Number)?.toLong() ?: map[name]?.toString()?.toLongOrNull() ?: throw JSONException("Not a long: $name")
    fun optLong(name: String): Long = optLong(name, 0L)
    fun optLong(name: String, fallback: Long): Long = (map[name] as? Number)?.toLong() ?: map[name]?.toString()?.toLongOrNull() ?: fallback

    fun getDouble(name: String): Double = (map[name] as? Number)?.toDouble() ?: map[name]?.toString()?.toDoubleOrNull() ?: throw JSONException("Not a double: $name")
    fun optDouble(name: String): Double = optDouble(name, 0.0)
    fun optDouble(name: String, fallback: Double): Double = (map[name] as? Number)?.toDouble() ?: map[name]?.toString()?.toDoubleOrNull() ?: fallback

    fun getBoolean(name: String): Boolean = (map[name] as? Boolean) ?: map[name]?.toString()?.toBoolean() ?: throw JSONException("Not a boolean: $name")
    fun optBoolean(name: String): Boolean = optBoolean(name, false)
    fun optBoolean(name: String, fallback: Boolean): Boolean = (map[name] as? Boolean) ?: map[name]?.toString()?.toBoolean() ?: fallback

    fun getJSONObject(name: String): JSONObject = (map[name] as? JSONObject) ?: throw JSONException("Not a JSONObject: $name")
    fun optJSONObject(name: String): JSONObject? = map[name] as? JSONObject

    fun getJSONArray(name: String): JSONArray = (map[name] as? JSONArray) ?: throw JSONException("Not a JSONArray: $name")
    fun optJSONArray(name: String): JSONArray? = map[name] as? JSONArray

    fun has(name: String): Boolean = map.containsKey(name)
    fun remove(name: String): Any? = map.remove(name)
    fun length(): Int = map.size
    fun keys(): Iterator<String> = map.keys.iterator()

    override fun toString(): String {
        val pairs = map.entries.joinToString(",") { (k, v) ->
            val vStr = when (v) {
                is String -> "\"${v.replace("\"", "\\\"")}\""
                null -> "null"
                else -> v.toString()
            }
            "\"$k\":$vStr"
        }
        return "{$pairs}"
    }
}

class JSONArray {
    private val list = mutableListOf<Any?>()

    constructor()
    constructor(json: String) {
        val trimmed = json.trim()
        if (trimmed.startsWith("[") && trimmed.endsWith("]")) {
            val body = trimmed.substring(1, trimmed.length - 1).trim()
            if (body.isNotEmpty()) {
                val tokens = body.split(",").map { it.trim() }
                for (t in tokens) {
                    list.add(when {
                        t == "true" -> true
                        t == "false" -> false
                        t == "null" -> null
                        t.startsWith("\"") && t.endsWith("\"") -> t.substring(1, t.length - 1)
                        t.startsWith("{") -> JSONObject(t)
                        t.startsWith("[") -> JSONArray(t)
                        else -> t.toLongOrNull() ?: t.toDoubleOrNull() ?: t
                    })
                }
            }
        }
    }
    constructor(collection: Collection<*>) {
        list.addAll(collection)
    }

    fun put(value: Any?): JSONArray {
        list.add(value)
        return this
    }

    fun length(): Int = list.size
    fun get(index: Int): Any = list[index] ?: throw JSONException("Index $index is null")
    fun opt(index: Int): Any? = list.getOrNull(index)
    fun getString(index: Int): String = list[index]?.toString() ?: throw JSONException("Index $index is null")
    fun optString(index: Int): String = list.getOrNull(index)?.toString() ?: ""
    fun optString(index: Int, fallback: String): String = list.getOrNull(index)?.toString() ?: fallback
    fun getInt(index: Int): Int = (list[index] as? Number)?.toInt() ?: list[index]?.toString()?.toIntOrNull() ?: throw JSONException("Not an int at $index")
    fun optInt(index: Int): Int = optInt(index, 0)
    fun optInt(index: Int, fallback: Int): Int = (list.getOrNull(index) as? Number)?.toInt() ?: list.getOrNull(index)?.toString()?.toIntOrNull() ?: fallback
    fun getLong(index: Int): Long = (list[index] as? Number)?.toLong() ?: list[index]?.toString()?.toLongOrNull() ?: throw JSONException("Not a long at $index")
    fun optLong(index: Int): Long = optLong(index, 0L)
    fun optLong(index: Int, fallback: Long): Long = (list.getOrNull(index) as? Number)?.toLong() ?: list.getOrNull(index)?.toString()?.toLongOrNull() ?: fallback
    fun getJSONObject(index: Int): JSONObject = (list[index] as? JSONObject) ?: throw JSONException("Index $index is not a JSONObject")
    fun optJSONObject(index: Int): JSONObject? = list.getOrNull(index) as? JSONObject
    fun getJSONArray(index: Int): JSONArray = (list[index] as? JSONArray) ?: throw JSONException("Index $index is not a JSONArray")
    fun optJSONArray(index: Int): JSONArray? = list.getOrNull(index) as? JSONArray

    override fun toString(): String = list.joinToString(prefix = "[", postfix = "]") {
        when (it) {
            is String -> "\"${it.replace("\"", "\\\"")}\""
            null -> "null"
            else -> it.toString()
        }
    }
}
