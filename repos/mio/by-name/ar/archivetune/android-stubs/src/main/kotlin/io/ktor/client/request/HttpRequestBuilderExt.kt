package io.ktor.client.request

fun HttpRequestBuilder.header(key: String, value: Any?) {}
inline fun <reified T> HttpRequestBuilder.setBody(body: T) {}
