package androidx.media3.datasource

import android.net.Uri

/*
 * media3's DataSource is Java, so Kotlin callers read its getters as properties. The port's fake is
 * a Kotlin interface (upstream *implements* it, so it must stay an interface), which cannot expose
 * getUri() as `.uri` as well - hence these extensions, injected by fix_theme.py where used.
 */
val DataSource.uri: Uri? get() = getUri()

val DataSource.responseHeaders: Map<String, List<String>> get() = getResponseHeaders()
