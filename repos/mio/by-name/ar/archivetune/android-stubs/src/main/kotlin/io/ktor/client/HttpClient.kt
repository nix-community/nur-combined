package io.ktor.client

import io.ktor.client.plugins.websocket.WebSockets
import io.ktor.client.plugins.websocket.WebSocketsConfig
import io.ktor.client.plugins.websocket.DefaultClientWebSocketSession

class HttpClientConfig<T> {
    fun engine(block: Any.() -> Unit) {}
    fun install(plugin: WebSockets, block: WebSocketsConfig.() -> Unit) {}
}

class HttpClient {
    suspend fun webSocket(
        urlString: String,
        request: Any.() -> Unit,
        block: suspend DefaultClientWebSocketSession.() -> Unit
    ) {}
}

fun HttpClient(engineFactory: Any, block: HttpClientConfig<*>.() -> Unit): HttpClient = HttpClient()
