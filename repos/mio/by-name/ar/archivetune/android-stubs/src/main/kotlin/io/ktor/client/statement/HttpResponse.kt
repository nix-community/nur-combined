package io.ktor.client.statement

import io.ktor.http.HttpStatusCode

open class HttpResponse {
    val status: HttpStatusCode = HttpStatusCode.OK
}
