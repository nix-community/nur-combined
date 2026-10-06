package io.noties.markwon.image

/*
 * markwon is Android-only, so the port keeps the builder chain used by MarkdownText. Upstream
 * calls `ImagesPlugin.create { plugin -> plugin.addSchemeHandler(...) }`, so there must be a
 * lambda-taking overload - with only the vararg form Kotlin rejects the trailing lambda.
 */
object ImagesPlugin {
    class ImagePlugin {
        fun addSchemeHandler(handler: Any?) {}
    }

    fun create(vararg args: Any?): Any = Any()

    fun create(block: (ImagePlugin) -> Unit): Any {
        block(ImagePlugin())
        return Any()
    }

    fun createWithSchemes(vararg args: Any?): Any = Any()
}
