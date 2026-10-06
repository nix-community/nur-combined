package androidx.core.graphics

/* androidx.core's color helpers; upstream converts stored colour strings with toColorInt(). */
fun String.toColorInt(): Int = 0

fun Int.toColorString(): String = ""

fun Long.toColorInt(): Int = 0
