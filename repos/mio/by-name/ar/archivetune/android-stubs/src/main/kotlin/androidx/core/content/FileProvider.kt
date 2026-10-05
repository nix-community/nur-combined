package androidx.core.content

import android.content.Context
import android.net.Uri
import java.io.File

open class FileProvider {
    companion object {
        fun getUriForFile(context: Context, authority: String, file: File): Uri = Uri()
    }
}
