package io.ktor.http

class HttpStatusCode(val value: Int, val description: String) {
    companion object {
        val OK = HttpStatusCode(200, "OK")
    }
}
