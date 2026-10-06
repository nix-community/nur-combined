package io.noties.markwon

import android.content.Context

/*
 * markwon is an Android-only markdown renderer (it produces android.text.Spannable),
 * so it cannot be consumed as a real JVM artifact. The port keeps the builder chain
 * used by MarkdownText; rendering returns the input text unchanged.
 */
class Markwon private constructor() {
    fun toMarkdown(text: String): CharSequence = text

    fun setParsedMarkdown(view: Any?, spanned: Any?) {}

    fun setMarkdown(view: Any?, markdown: Any?) {}

    class Builder {
        fun usePlugin(plugin: Any): Builder = this

        fun usePlugins(vararg plugins: Any): Builder = this

        fun build(): Markwon = Markwon()
    }

    companion object {
        fun builder(context: Context): Builder = Builder()
    }
}
