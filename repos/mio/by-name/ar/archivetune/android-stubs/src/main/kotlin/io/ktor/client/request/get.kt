package io.ktor.client.request


import io.ktor.client.HttpClient
import io.ktor.client.statement.HttpResponse
suspend inline fun HttpClient.get(urlString: String, block: HttpRequestBuilder.() -> Unit = {}): HttpResponse = TODO()

