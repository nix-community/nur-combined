package org.json

open class JSONObject {
    constructor()
    constructor(json: String)
    open fun optJSONArray(name: String): JSONArray? = null
    open fun getJSONObject(name: String): JSONObject = JSONObject("")
    open fun optJSONObject(name: String): JSONObject? = null
    open fun optString(name: String, fallback: String = ""): String = ""
    open fun put(name: String, value: Any?): JSONObject = this
    open fun isNull(name: String): Boolean = false

    
    companion object {
        val NULL = Any()
    }
}

open class JSONArray {
    constructor()
    constructor(json: String)
    open fun length(): Int = 0
    open fun getJSONObject(index: Int): JSONObject = JSONObject("")
    open fun optJSONObject(index: Int): JSONObject? = null
    open fun opt(index: Int): Any? = null
    open fun put(value: Any?): JSONArray = this
}
