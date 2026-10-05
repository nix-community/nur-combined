package io.ktor.client.engine.okhttp

import io.ktor.client.HttpClientConfig

object OkHttp

class OkHttpConfig {
    fun config(block: Any.() -> Unit) {}
}

fun HttpClientConfig<Any>.engine(block: OkHttpConfig.() -> Unit) {}
