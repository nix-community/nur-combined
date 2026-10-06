package androidx.compose.ui.graphics

/*
 * The Android Compose artefact provides `android.graphics.Bitmap.asImageBitmap()`, but the port
 * compiles against Compose Desktop, which does not - so every `bitmap.asImageBitmap()` call in
 * upstream fails with a receiver mismatch. Same FQN as the Android extension, so nothing clashes.
 */
fun android.graphics.Bitmap.asImageBitmap(): ImageBitmap =
    ImageBitmap(width.coerceAtLeast(1), height.coerceAtLeast(1))
