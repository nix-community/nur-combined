package coil3

import android.graphics.Bitmap
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.toComposeImageBitmap
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.ByteArrayInputStream
import java.io.File
import java.security.MessageDigest
import java.util.Collections
import java.util.LinkedHashMap
import java.util.concurrent.TimeUnit
import javax.imageio.ImageIO

object DesktopImageLoader {
    private val client by lazy {
        OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .readTimeout(15, TimeUnit.SECONDS)
            .followRedirects(true)
            .followSslRedirects(true)
            .build()
    }

    private const val MAX_MEMORY_CACHE_ENTRIES = 300

    private val memoryCache: MutableMap<String, LoadedImage> =
        Collections.synchronizedMap(
            object : LinkedHashMap<String, LoadedImage>(MAX_MEMORY_CACHE_ENTRIES, 0.75f, true) {
                override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, LoadedImage>?): Boolean {
                    return size > MAX_MEMORY_CACHE_ENTRIES
                }
            }
        )

    private val diskCacheDir by lazy {
        val home = System.getProperty("user.home", ".")
        val dir = File(home, ".cache/archivetune/images")
        if (!dir.exists()) {
            dir.mkdirs()
        }
        dir
    }

    data class LoadedImage(
        val imageBitmap: ImageBitmap,
        val bitmap: Bitmap?,
    )

    fun resolveModel(model: Any?): Any? = when (model) {
        null -> null
        is coil3.request.ImageRequest -> model.data
        is android.net.Uri -> model.toString()
        is coil3.Uri -> model.toString()
        is java.net.URI -> model.toString()
        is java.net.URL -> model.toString()
        else -> model
    }

    fun getCacheKey(data: Any?): String? = when (data) {
        is String -> data
        is File -> data.absolutePath
        is ByteArray -> "bytes_${data.hashCode()}_${data.size}"
        else -> data?.toString()
    }

    fun getMemoryCached(key: String?): LoadedImage? {
        if (key == null) return null
        return memoryCache[key]
    }

    private fun hashUrl(url: String): String {
        return try {
            val md = MessageDigest.getInstance("SHA-256")
            val digest = md.digest(url.toByteArray(Charsets.UTF_8))
            digest.joinToString("") { "%02x".format(it) }
        } catch (_: Exception) {
            url.hashCode().toString()
        }
    }

    fun fetchBytes(data: Any?): ByteArray? {
        val resolved = resolveModel(data) ?: return null
        return when (resolved) {
            is ByteArray -> resolved
            is File -> if (resolved.exists()) resolved.readBytes() else null
            is String -> {
                when {
                    resolved.startsWith("http://", ignoreCase = true) || resolved.startsWith("https://", ignoreCase = true) -> {
                        // Check disk cache first
                        val hash = hashUrl(resolved)
                        val cachedFile = File(diskCacheDir, hash)
                        if (cachedFile.exists() && cachedFile.length() > 0) {
                            try {
                                return cachedFile.readBytes()
                            } catch (_: Exception) {}
                        }

                        // Download over network
                        try {
                            val request = Request.Builder()
                                .url(resolved)
                                .header("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
                                .build()
                            client.newCall(request).execute().use { response ->
                                if (response.isSuccessful) {
                                    val body = response.body
                                    val bytes = body?.bytes()
                                    if (bytes != null && bytes.isNotEmpty()) {
                                        try {
                                            val tmpFile = File(diskCacheDir, "$hash.tmp")
                                            tmpFile.writeBytes(bytes)
                                            tmpFile.renameTo(cachedFile)
                                        } catch (_: Exception) {}
                                        return bytes
                                    }
                                }
                            }
                        } catch (_: Exception) {}
                        null
                    }
                    resolved.startsWith("file://", ignoreCase = true) -> {
                        try {
                            val path = resolved.removePrefix("file://")
                            val file = File(path)
                            if (file.exists()) file.readBytes() else null
                        } catch (_: Exception) {
                            null
                        }
                    }
                    resolved.startsWith("/") -> {
                        try {
                            val file = File(resolved)
                            if (file.exists()) file.readBytes() else null
                        } catch (_: Exception) {
                            null
                        }
                    }
                    else -> null
                }
            }
            else -> null
        }
    }

    fun decodeLoadedImage(bytes: ByteArray): LoadedImage? {
        if (bytes.isEmpty()) return null
        // Try native Skia decoding first
        try {
            val skiaImg: org.jetbrains.skia.Image? = org.jetbrains.skia.Image.makeFromEncoded(bytes)
            if (skiaImg != null) {
                val composeBitmap = skiaImg.toComposeImageBitmap()
                val bais = ByteArrayInputStream(bytes)
                val bufferedImage = try { ImageIO.read(bais) } catch (_: Throwable) { null }
                val androidBitmap = Bitmap(bufferedImage = bufferedImage, imageBitmap = composeBitmap)
                return LoadedImage(imageBitmap = composeBitmap, bitmap = androidBitmap)
            }
        } catch (_: Throwable) {}

        // Fallback to ImageIO / AWT decoding
        return try {
            val bais = ByteArrayInputStream(bytes)
            val bufferedImage = ImageIO.read(bais) ?: return null
            val composeBitmap = bufferedImage.toComposeImageBitmap()
            val androidBitmap = Bitmap(bufferedImage = bufferedImage, imageBitmap = composeBitmap)
            LoadedImage(imageBitmap = composeBitmap, bitmap = androidBitmap)
        } catch (_: Throwable) {
            null
        }
    }

    fun load(data: Any?): LoadedImage? {
        val key = getCacheKey(data)
        if (key != null) {
            memoryCache[key]?.let { return it }
        }
        val bytes = fetchBytes(data) ?: return null
        val decoded = decodeLoadedImage(bytes) ?: return null
        if (key != null) {
            memoryCache[key] = decoded
        }
        return decoded
    }
}
