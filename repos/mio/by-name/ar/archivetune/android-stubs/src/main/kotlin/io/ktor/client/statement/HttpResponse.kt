package io.ktor.client.statement

import io.ktor.http.HttpStatusCode

open class HttpResponse {
    open val status: HttpStatusCode = HttpStatusCode()
    open val headers: io.ktor.http.Headers = io.ktor.http.Headers()
}

fun HttpResponse.bodyAsText(): String = ""
