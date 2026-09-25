package io.ktor.client.engine.okhttp

import okhttp3.OkHttpClient

object OkHttp

class OkHttpConfig {
    fun config(block: OkHttpClient.Builder.() -> Unit) {}
}
