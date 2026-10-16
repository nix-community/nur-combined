package dagger.hilt.android

import java.lang.reflect.Proxy

object EntryPointAccessors {
    @Suppress("UNCHECKED_CAST")
    fun <T> fromApplication(context: android.content.Context, entryPoint: Class<T>): T {
        if (entryPoint.name == "moe.rukamori.archivetune.di.LyricsHelperEntryPoint") {
            try {
                val observerClass = Class.forName("moe.rukamori.archivetune.utils.NetworkConnectivityObserver")
                val observerConstructor = observerClass.getConstructor(android.content.Context::class.java)
                val observer = observerConstructor.newInstance(context)

                val lyricsHelperClass = Class.forName("moe.rukamori.archivetune.lyrics.LyricsHelper")
                val lyricsHelperConstructor = lyricsHelperClass.getConstructor(
                    android.content.Context::class.java,
                    observerClass
                )
                val lyricsHelper = lyricsHelperConstructor.newInstance(context, observer)

                return Proxy.newProxyInstance(
                    entryPoint.classLoader,
                    arrayOf(entryPoint)
                ) { _, method, _ ->
                    if (method.name == "lyricsHelper") lyricsHelper else null
                } as T
            } catch (t: Throwable) {
                System.err.println("[EntryPointAccessors] Warning: failed to construct LyricsHelper: ${t.message}")
            }
        }

        return Proxy.newProxyInstance(
            entryPoint.classLoader,
            arrayOf(entryPoint)
        ) { _, method, _ ->
            val ret = method.returnType
            when {
                ret == Boolean::class.java || ret == java.lang.Boolean.TYPE -> false
                ret == Int::class.java || ret == java.lang.Integer.TYPE -> 0
                ret == Long::class.java || ret == java.lang.Long.TYPE -> 0L
                else -> null
            }
        } as T
    }
}
