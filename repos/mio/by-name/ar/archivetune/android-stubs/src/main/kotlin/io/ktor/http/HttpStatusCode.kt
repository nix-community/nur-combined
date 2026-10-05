package io.ktor.http

open class HttpStatusCode {
    open val value: Int = 0
    companion object {
        val BadRequest: HttpStatusCode = HttpStatusCode()
        val Forbidden: HttpStatusCode = HttpStatusCode()
        val NotModified: HttpStatusCode = HttpStatusCode()
    }
}

open class Headers {
    operator fun get(name: String): String? = null
}
