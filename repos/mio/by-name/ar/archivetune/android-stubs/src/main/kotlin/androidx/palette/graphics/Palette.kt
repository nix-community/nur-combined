package androidx.palette.graphics

import android.graphics.Bitmap

open class Palette {
    companion object {
        fun from(bitmap: Bitmap): Builder = Builder()
    }
    class Builder {
        fun maximumColorCount(colors: Int): Builder = this

        fun resizeBitmapArea(bitmapArea: Int): Builder = this

        fun clearFilters(): Builder = this

        fun addFilter(filter: Any): Builder = this

        fun generate(): Palette = Palette()
    }
    class Swatch(val rgb: Int, val population: Int)
    
    val vibrantSwatch: Swatch? = null
    val dominantSwatch: Swatch? = null
    val mutedSwatch: Swatch? = null
    val lightVibrantSwatch: Swatch? = null
    val darkVibrantSwatch: Swatch? = null
    val lightMutedSwatch: Swatch? = null
    val darkMutedSwatch: Swatch? = null
    val swatches: List<Swatch> = emptyList()
}
