package io.ktor.client.plugins.websocket

object WebSockets

class WebSocketsConfig {
    var pingIntervalMillis: Long = 0L
}

interface DefaultClientWebSocketSession {
    suspend fun send(frame: Any)
}
