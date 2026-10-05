package io.ktor.client.plugins

import io.ktor.http.HttpStatusCode
import io.ktor.client.statement.HttpResponse

open class ClientRequestException : RuntimeException() {
    open val response: HttpResponse = HttpResponse()
}
