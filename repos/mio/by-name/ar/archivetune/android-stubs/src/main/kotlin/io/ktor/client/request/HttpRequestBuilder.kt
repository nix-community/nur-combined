package io.ktor.client.request
import io.ktor.client.statement.HttpResponse

open class HttpRequestBuilder {
    fun header(key: String, value: String) {}
    fun setBody(body: Any) {}
}

suspend fun io.ktor.client.HttpClient.post(urlString: String, block: HttpRequestBuilder.() -> Unit = {}): HttpResponse = TODO()
