package android.graphics

class Color {
    companion object {
        fun HSVToColor(hsv: FloatArray): Int {
            return HSVToColor(0xFF, hsv)
        }

        fun HSVToColor(alpha: Int, hsv: FloatArray): Int {
            val h = (hsv.getOrNull(0) ?: 0f) / 360f
            val s = (hsv.getOrNull(1) ?: 0f).coerceIn(0f, 1f)
            val v = (hsv.getOrNull(2) ?: 0f).coerceIn(0f, 1f)
            val rgb = java.awt.Color.HSBtoRGB(h, s, v)
            return ((alpha and 0xFF) shl 24) or (rgb and 0x00FFFFFF)
        }

        fun colorToHSV(color: Int, hsv: FloatArray) {
            val r = (color ushr 16) and 0xFF
            val g = (color ushr 8) and 0xFF
            val b = color and 0xFF
            val hsb = FloatArray(3)
            java.awt.Color.RGBtoHSB(r, g, b, hsb)
            hsv[0] = hsb[0] * 360f
            hsv[1] = hsb[1]
            hsv[2] = hsb[2]
        }

        fun argb(alpha: Int, red: Int, green: Int, blue: Int): Int {
            return ((alpha and 0xFF) shl 24) or
                ((red and 0xFF) shl 16) or
                ((green and 0xFF) shl 8) or
                (blue and 0xFF)
        }

        fun parseColor(colorString: String): Int {
            val s = colorString.removePrefix("#")
            return when (s.length) {
                6 -> (0xFF shl 24) or s.toLong(16).toInt()
                8 -> s.toLong(16).toInt()
                else -> 0
            }
        }
    }
}
