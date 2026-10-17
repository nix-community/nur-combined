package androidx.compose.ui.res

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.graphics.painter.ColorPainter
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.graphics.toComposeImageBitmap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Density
import org.xml.sax.InputSource
import java.io.InputStream
import java.io.StringReader
import java.util.concurrent.ConcurrentHashMap
import javax.imageio.ImageIO

private val vectorCache = ConcurrentHashMap<String, ImageVector>()
private val bitmapCache = ConcurrentHashMap<String, ImageBitmap>()

@Composable
fun painterResource(id: Int): Painter {
    val name = DrawableResources.getName(id) ?: return ColorPainter(Color.Transparent)
    return rememberDrawablePainter(name)
}

@Composable
fun painterResource(resourcePath: String): Painter {
    val name = resourcePath
        .removePrefix("/")
        .removePrefix("drawable/")
        .substringBeforeLast(".")
    return rememberDrawablePainter(name)
}

@Composable
fun rememberDrawablePainter(name: String): Painter {
    val density = LocalDensity.current
    val vector = remember(name, density) {
        loadVectorResource(name, density)
    }
    if (vector != null) {
        return rememberVectorPainter(vector)
    }

    val bitmap = remember(name) {
        loadBitmapResource(name)
    }
    if (bitmap != null) {
        return BitmapPainter(bitmap)
    }

    return ColorPainter(Color.Transparent)
}

private fun loadVectorResource(name: String, density: Density): ImageVector? {
    val cacheKey = "$name@${density.density}"
    vectorCache[cacheKey]?.let { return it }

    val stream = openResource("drawable/$name.xml") ?: return null
    return try {
        val raw = stream.bufferedReader(Charsets.UTF_8).use { it.readText() }
        val sanitized = sanitizeVectorXml(raw)
        val vector = loadXmlImageVector(
            InputSource(StringReader(sanitized)),
            density
        )
        vectorCache[cacheKey] = vector
        vector
    } catch (e: Throwable) {
        System.err.println("Warning: failed to parse vector drawable $name: $e")
        null
    }
}

private fun loadBitmapResource(name: String): ImageBitmap? {
    bitmapCache[name]?.let { return it }

    val stream = openResource("drawable/$name.png")
        ?: openResource("drawable/$name.jpg")
        ?: return null
    return try {
        val buffered = stream.use { ImageIO.read(it) } ?: return null
        val bitmap = buffered.toComposeImageBitmap()
        bitmapCache[name] = bitmap
        bitmap
    } catch (e: Throwable) {
        System.err.println("Warning: failed to load bitmap drawable $name: $e")
        null
    }
}

private fun openResource(path: String): InputStream? {
    val clean = path.removePrefix("/")
    return Thread.currentThread().contextClassLoader?.getResourceAsStream(clean)
        ?: DrawableResources::class.java.classLoader?.getResourceAsStream(clean)
        ?: ClassLoader.getSystemResourceAsStream(clean)
}

private fun sanitizeVectorXml(raw: String): String {
    return raw
        .replace("dip\"", "dp\"")
        .replace("dip<", "dp<")
        .replace("dip ", "dp ")
        .replace("@android:color/white", "#ffffffff")
        .replace("@android:color/black", "#ff000000")
        .replace("@android:color/transparent", "#00000000")
        .replace(Regex("@(?:android:)?color/[a-zA-Z0-9_]+"), "#ffffffff")
}
