package com.caverock.androidsvg

import android.graphics.Picture

class SVG {
    fun renderToPicture(): Picture = Picture()
    fun setDocumentWidth(width: Float) {}
    fun setDocumentHeight(height: Float) {}
    fun getDocumentWidth(): Float = 0f
    fun getDocumentHeight(): Float = 0f
    
    companion object {
        fun getFromString(svg: String): SVG = SVG()
    }
}
