package io.ktor.client

import io.ktor.client.engine.okhttp.OkHttpConfig

class HttpClient(engine: Any? = null, block: HttpClientConfig.() -> Unit = {})

class HttpClientConfig {
    fun engine(block: OkHttpConfig.() -> Unit) {}
}
