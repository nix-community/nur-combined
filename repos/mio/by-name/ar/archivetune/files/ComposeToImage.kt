package moe.rukamori.archivetune.utils

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.view.View
import moe.rukamori.archivetune.ui.component.LyricsShareImageOptions

object ComposeToImage {
    suspend fun captureViewBitmap(
        view: View,
        targetWidth: Int? = null,
        targetHeight: Int? = null,
        backgroundColor: Int? = null,
    ): Bitmap = Bitmap()

    fun cropBitmap(
        source: Bitmap,
        left: Int,
        top: Int,
        width: Int,
        height: Int,
    ): Bitmap = source

    fun fitBitmap(
        source: Bitmap,
        targetWidth: Int,
        targetHeight: Int,
        backgroundColor: Int,
    ): Bitmap = source

    suspend fun createLyricsImage(
        context: Context,
        coverArtUrl: String?,
        songTitle: String,
        artistName: String,
        lyrics: String,
        width: Int,
        height: Int,
        backgroundColor: Int? = null,
        textColor: Int? = null,
        secondaryTextColor: Int? = null,
        glassStyle: moe.rukamori.archivetune.ui.component.LyricsGlassStyle? = null,
        shareOptions: LyricsShareImageOptions = LyricsShareImageOptions(),
    ): Bitmap = Bitmap()

    fun saveBitmapAsFile(
        context: Context,
        bitmap: Bitmap,
        fileName: String,
    ): Uri = Uri.EMPTY
}
