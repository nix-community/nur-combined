package okhttp3

import java.util.concurrent.TimeUnit

/*
 * OkHttp 5 keeps `writeTimeout(long, TimeUnit)` and `retryOnConnectionFailure(boolean)`
 * in the bytecode but hides them from Kotlin (deprecated with DeprecationLevel.HIDDEN),
 * so upstream call sites inside ktor's OkHttp engine `config { }` block fail to resolve
 * against the real artifact. The port restores them as inert extensions; fix_theme.py
 * injects the imports where they are used.
 */
fun OkHttpClient.Builder.writeTimeout(timeout: Long, unit: TimeUnit): OkHttpClient.Builder = this

fun OkHttpClient.Builder.retryOnConnectionFailure(retry: Boolean): OkHttpClient.Builder = this
