package androidx.palette.graphics

import android.graphics.Bitmap

open class Palette(
    val dominantSwatch: Swatch? = null,
    val vibrantSwatch: Swatch? = null,
    val mutedSwatch: Swatch? = null,
    val darkVibrantSwatch: Swatch? = null,
    val lightVibrantSwatch: Swatch? = null,
    val darkMutedSwatch: Swatch? = null,
    val lightMutedSwatch: Swatch? = null,
    val swatches: List<Swatch> = emptyList(),
) {
    companion object {
        fun from(bitmap: Bitmap): Builder = Builder(bitmap)
    }

    class Builder(private val bitmap: Bitmap) {
        fun maximumColorCount(colors: Int): Builder = this

        fun resizeBitmapArea(bitmapArea: Int): Builder = this

        fun clearFilters(): Builder = this

        fun addFilter(filter: Any): Builder = this

        fun generate(): Palette {
            val w = bitmap.width
            val h = bitmap.height
            if (w <= 0 || h <= 0) return Palette()

            val stepX = maxOf(1, w / 16)
            val stepY = maxOf(1, h / 16)
            var totalR = 0L
            var totalG = 0L
            var totalB = 0L
            var count = 0
            val pixels = IntArray(1)

            for (y in 0 until h step stepY) {
                for (x in 0 until w step stepX) {
                    bitmap.getPixels(pixels, 0, 1, x, y, 1, 1)
                    val argb = pixels[0]
                    val a = (argb ushr 24) and 0xFF
                    if (a > 128) {
                        totalR += (argb ushr 16) and 0xFF
                        totalG += (argb ushr 8) and 0xFF
                        totalB += argb and 0xFF
                        count++
                    }
                }
            }

            if (count == 0) return Palette()

            val avgR = (totalR / count).toInt()
            val avgG = (totalG / count).toInt()
            val avgB = (totalB / count).toInt()
            val dominantRgb = (0xFF shl 24) or (avgR shl 16) or (avgG shl 8) or avgB
            val darkRgb = (0xFF shl 24) or ((avgR * 0.6).toInt() shl 16) or ((avgG * 0.6).toInt() shl 8) or (avgB * 0.6).toInt()
            val vibrantRgb = (0xFF shl 24) or (minOf(255, (avgR * 1.3).toInt()) shl 16) or (minOf(255, (avgG * 1.3).toInt()) shl 8) or minOf(255, (avgB * 1.3).toInt())

            val dom = Swatch(dominantRgb, count)
            val vib = Swatch(vibrantRgb, count)
            val darkVib = Swatch(darkRgb, count)

            return Palette(
                dominantSwatch = dom,
                vibrantSwatch = vib,
                mutedSwatch = dom,
                darkVibrantSwatch = darkVib,
                lightVibrantSwatch = vib,
                darkMutedSwatch = darkVib,
                lightMutedSwatch = vib,
                swatches = listOf(dom, vib, darkVib),
            )
        }
    }

    class Swatch(val rgb: Int, val population: Int)
}
