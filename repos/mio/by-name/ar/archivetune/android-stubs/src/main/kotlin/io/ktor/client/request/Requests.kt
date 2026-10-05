package io.ktor.client.request

import io.ktor.client.HttpClient
import io.ktor.client.statement.HttpResponse

class HeadersBuilder {
    fun append(name: String, value: String) {}
}

class HttpRequestBuilder

fun HttpRequestBuilder.headers(block: HeadersBuilder.() -> Unit) {}
fun HttpRequestBuilder.parameter(key: String, value: Any?) {}
fun HttpRequestBuilder.header(key: String, value: Any?) {}
fun HttpRequestBuilder.setBody(body: Any) {}

suspend fun HttpClient.get(urlString: String, block: HttpRequestBuilder.() -> Unit = {}): HttpResponse = HttpResponse()
suspend fun HttpClient.post(urlString: String, block: HttpRequestBuilder.() -> Unit = {}): HttpResponse = HttpResponse()
