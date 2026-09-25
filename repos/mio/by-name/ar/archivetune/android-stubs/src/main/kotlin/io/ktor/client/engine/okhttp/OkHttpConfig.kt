package io.ktor.client.engine.okhttp


open class OkHttpConfig {
    var config: (Any.() -> Unit)? = null
}

