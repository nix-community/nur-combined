package moe.rukamori.archivetune.lrclib

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import java.util.concurrent.TimeUnit

object LrcLib {
    var logger: (String) -> Unit = {}

    private val client by lazy {
        OkHttpClient.Builder()
            .connectTimeout(10, TimeUnit.SECONDS)
            .readTimeout(10, TimeUnit.SECONDS)
            .build()
    }

    private val jsonParser by lazy {
        Json { ignoreUnknownKeys = true }
    }

    suspend fun getLyrics(
        title: String,
        artist: String,
        duration: Int = 0,
        album: String? = null,
    ): Result<String> = withContext(Dispatchers.IO) {
        val cleanTitle = title.trim()
        val cleanArtist = artist.trim()
        if (cleanTitle.isBlank()) return@withContext Result.failure(IllegalArgumentException("Title is blank"))

        // 1. Try exact get endpoint
        val getUrlBuilder = "https://lrclib.net/api/get".toHttpUrlOrNull()?.newBuilder()
        if (getUrlBuilder != null) {
            getUrlBuilder.addQueryParameter("track_name", cleanTitle)
            getUrlBuilder.addQueryParameter("artist_name", cleanArtist)
            if (duration > 0) {
                getUrlBuilder.addQueryParameter("duration", duration.toString())
            }
            if (!album.isNullOrBlank()) {
                getUrlBuilder.addQueryParameter("album_name", album.trim())
            }

            try {
                val request = Request.Builder()
                    .url(getUrlBuilder.build())
                    .header("User-Agent", "ArchiveTune-Desktop/15.1.0")
                    .build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string()
                        if (!body.isNullOrBlank()) {
                            val obj = jsonParser.parseToJsonElement(body).jsonObject
                            val synced = obj["syncedLyrics"]?.jsonPrimitive?.contentOrNull?.takeIf { it.isNotBlank() }
                            val plain = obj["plainLyrics"]?.jsonPrimitive?.contentOrNull?.takeIf { it.isNotBlank() }
                            val resultLyrics = synced ?: plain
                            if (resultLyrics != null) {
                                return@withContext Result.success(resultLyrics)
                            }
                        }
                    }
                }
            } catch (t: Throwable) {
                logger("LrcLib exact get error: ${t.message}")
            }
        }

        // 2. Fallback to search endpoint
        val searchUrlBuilder = "https://lrclib.net/api/search".toHttpUrlOrNull()?.newBuilder()
        if (searchUrlBuilder != null) {
            val query = if (cleanArtist.isNotBlank()) "$cleanTitle $cleanArtist" else cleanTitle
            searchUrlBuilder.addQueryParameter("q", query)

            try {
                val request = Request.Builder()
                    .url(searchUrlBuilder.build())
                    .header("User-Agent", "ArchiveTune-Desktop/15.1.0")
                    .build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string()
                        if (!body.isNullOrBlank()) {
                            val array = jsonParser.parseToJsonElement(body).jsonArray
                            for (element in array) {
                                val item = element.jsonObject
                                val synced = item["syncedLyrics"]?.jsonPrimitive?.contentOrNull?.takeIf { it.isNotBlank() }
                                val plain = item["plainLyrics"]?.jsonPrimitive?.contentOrNull?.takeIf { it.isNotBlank() }
                                val resultLyrics = synced ?: plain
                                if (resultLyrics != null) {
                                    return@withContext Result.success(resultLyrics)
                                }
                            }
                        }
                    }
                }
            } catch (t: Throwable) {
                logger("LrcLib search error: ${t.message}")
            }
        }

        Result.failure(NoSuchElementException("No lyrics found on LrcLib for $cleanTitle - $cleanArtist"))
    }

    suspend fun getAllLyrics(
        title: String,
        artist: String,
        duration: Int = 0,
        album: String? = null,
        callback: ((String) -> Unit)? = null,
    ): Result<String>? {
        val result = getLyrics(title, artist, duration, album)
        result.getOrNull()?.let { callback?.invoke(it) }
        return result
    }
}
