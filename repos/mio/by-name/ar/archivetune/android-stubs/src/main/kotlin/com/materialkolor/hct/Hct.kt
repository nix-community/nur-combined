package com.materialkolor.hct

class Hct(val hue: Double, val chroma: Double, val tone: Double) {
    companion object {
        fun from(hue: Double, chroma: Double, tone: Double) = Hct(hue, chroma, tone)
    }
    fun withTone(tone: Double) = Hct(hue, chroma, tone)
}
