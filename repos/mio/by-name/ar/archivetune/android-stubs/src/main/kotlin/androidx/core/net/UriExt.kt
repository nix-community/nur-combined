package androidx.core.net

import android.net.Uri

fun String.toUri(): Uri = Uri.parse(this)
