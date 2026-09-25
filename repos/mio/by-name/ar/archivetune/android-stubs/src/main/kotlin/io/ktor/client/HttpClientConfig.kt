package io.ktor.client


open class HttpClientConfig<T> {
    fun engine(block: T.() -> Unit) {}
}

