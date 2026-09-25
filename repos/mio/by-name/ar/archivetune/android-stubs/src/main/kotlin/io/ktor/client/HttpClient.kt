package io.ktor.client


class HttpClient(engine: Any? = null, block: HttpClientConfig<*>.() -> Unit = {}) {
    suspend inline fun <reified T> get(url: String): T = TODO()
}

