package io.ktor.client.request


import io.ktor.client.request.HttpRequestBuilder
open class HeadersBuilder {
    fun append(name: String, value: String) {}
}
fun HttpRequestBuilder.headers(block: HeadersBuilder.() -> Unit) {}

