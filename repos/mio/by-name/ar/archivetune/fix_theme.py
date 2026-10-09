import re
with open('app/src/main/kotlin/moe/rukamori/archivetune/ui/theme/Theme.kt', 'r') as f:
    c = f.read()

# Replace MaterialExpressiveTheme
c = re.sub(
    r'MaterialExpressiveTheme\(\s*colorScheme = animatedColorScheme,\s*motionScheme = motionScheme,\s*typography = typography,\s*shapes = expressiveShapes,\s*content = content,\s*\)',
    r'androidx.compose.material3.MaterialTheme(\n            colorScheme = animatedColorScheme,\n            typography = typography,\n            content = content,\n        )',
    c, flags=re.MULTILINE
)

c = re.sub(
    r'MaterialExpressiveTheme\(\s*colorScheme = animatedColorScheme,\s*motionScheme = motionScheme,\s*typography = typography,\s*shape = expressiveShapes,\s*content = content,\s*\)',
    r'androidx.compose.material3.MaterialTheme(\n            colorScheme = animatedColorScheme,\n            typography = typography,\n            content = content,\n        )',
    c, flags=re.MULTILINE
)

# Replace motionScheme usage
c = re.sub(
    r'val motionScheme =\s*remember\(disableAnimations\) \{\s*if \(disableAnimations\) DisabledMotionScheme else MotionScheme\.expressive\(\)\s*\}',
    '',
    c, flags=re.DOTALL
)
c = re.sub(
    r'@OptIn\(ExperimentalMaterial3ExpressiveApi::class\)\s*private object DisabledMotionScheme : MotionScheme \{.*?\n\}\n',
    '',
    c, flags=re.DOTALL
)

# Remove animateColorScheme usages
c = re.sub(
    r'val animatedColorScheme =\s*if \(disableAnimations\) \{\s*colorScheme\s*\} else \{\s*animateColorScheme\(\s*targetColorScheme = colorScheme,\s*animationSpec = motionScheme\.defaultEffectsSpec\(\),\s*\)\s*\}',
    'val animatedColorScheme = colorScheme',
    c, flags=re.DOTALL
)

# Replace dynamicDarkColorScheme and dynamicLightColorScheme FOR REAL THIS TIME!
c = re.sub(r'dynamicDarkColorScheme\(.*?\)', 'androidx.compose.material3.darkColorScheme()', c, flags=re.DOTALL)
c = re.sub(r'dynamicLightColorScheme\(.*?\)', 'androidx.compose.material3.lightColorScheme()', c, flags=re.DOTALL)

# Remove dynamicColorScheme
c = re.sub(
    r'dynamicColorScheme\(\s*seedColor = seedColor,\s*isDark = isDark,\s*contrastLevel = contrastLevel,\s*style = style,\s*\)',
    r'if (isDark) androidx.compose.material3.darkColorScheme() else androidx.compose.material3.lightColorScheme()',
    c, flags=re.DOTALL
)

# Remove dynamic imports
c = re.sub(r'import com.materialkolor.dynamic.*?\n', '', c, flags=re.MULTILINE)
c = re.sub(r'import androidx.compose.material3.MaterialExpressiveTheme.*?\n', '', c, flags=re.MULTILINE)
c = re.sub(r'import androidx.compose.material3.MotionScheme.*?\n', '', c, flags=re.MULTILINE)
c = re.sub(r'import androidx.compose.material3.dynamicDarkColorScheme.*?\n', '', c, flags=re.MULTILINE)
c = re.sub(r'import androidx.compose.material3.dynamicLightColorScheme.*?\n', '', c, flags=re.MULTILINE)


c = c.replace('LocalArchiveTuneFontFamily provides resolvedFontFamily,', 'LocalArchiveTuneFontFamily provides (resolvedFontFamily as androidx.compose.ui.text.font.SystemFontFamily),')
c = re.sub(r'fun Bitmap\.extractThemeColor\(\): Color \{.*?\n\}', 'fun Bitmap.extractThemeColor(): Color { return DefaultThemeColor }', c, flags=re.DOTALL)
c = re.sub(r'fun Bitmap\.extractGradientColors\(\): List<Color> \{.*?\n\}', 'fun Bitmap.extractGradientColors(): List<Color> { return listOf(androidx.compose.ui.graphics.Color(0xFF595959), androidx.compose.ui.graphics.Color(0xFF0D0D0D)) }', c, flags=re.DOTALL)
c = re.sub(r'fun extractWallpaperThemeColor\(context: Context\): Color\? \{.*?\n\}', 'fun extractWallpaperThemeColor(context: Context): Color? { return null }', c, flags=re.DOTALL)

with open('app/src/main/kotlin/moe/rukamori/archivetune/ui/theme/Theme.kt', 'w') as f:
    f.write(c)

with open('app/src/main/kotlin/moe/rukamori/archivetune/ui/theme/Type.kt', 'r') as f:
    c = f.read()

c = c.replace('val AppFontFamily = FontFamily(Font(R.font.poppins))', 'val AppFontFamily = androidx.compose.ui.text.font.FontFamily.Default as androidx.compose.ui.text.font.SystemFontFamily')
c = c.replace('val LyricsFontFamily = FontFamily(Font(R.font.sfprodisplaybold))', 'val LyricsFontFamily = androidx.compose.ui.text.font.FontFamily.Default as androidx.compose.ui.text.font.SystemFontFamily')

with open('app/src/main/kotlin/moe/rukamori/archivetune/ui/theme/Type.kt', 'w') as f:
    f.write(c)

with open('app/src/main/kotlin/moe/rukamori/archivetune/ui/svg/DynamicSVGImage.kt', 'w') as f:
    f.write("""package moe.rukamori.archivetune.ui.svg

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import moe.rukamori.archivetune.ui.theme.palette.TonalPalettes

/*
 * The real implementation renders SVG through com.caverock.androidsvg and android.graphics.Picture,
 * which the desktop port has no equivalent for. Call sites in upstream pass svgImageString /
 * tonalPalettes / isDarkTheme, so the parameter names must match exactly.
 */
@Composable
fun DynamicSVGImage(
    svgImageString: String,
    tonalPalettes: TonalPalettes,
    isDarkTheme: Boolean,
    modifier: Modifier = Modifier,
) {}
""")

with open('app/src/main/kotlin/moe/rukamori/archivetune/ui/theme/CustomFontLoader.kt', 'w') as f:
    f.write("""package moe.rukamori.archivetune.ui.theme

import android.content.Context
import android.net.Uri
import androidx.compose.ui.text.font.FontFamily

object CustomFontLoader {
    // Upstream's font picker launches with this array; omitting it was an unresolved reference.
    val supportedMimeTypes =
        arrayOf(
            "font/ttf",
            "application/x-font-ttf",
            "application/x-font-truetype",
            "application/octet-stream",
        )

    fun displayName(context: Context, uri: Uri): String = ""
    fun isSupportedTtf(context: Context, uri: Uri): Boolean = false
    suspend fun loadFontFamily(context: Context, uriString: String): FontFamily? = androidx.compose.ui.text.font.FontFamily.Default
}
""")

import glob

# compose 1.9 gives Modifier.clickable's `indication` a default; 1.7 requires it. Only the call
# site that omits it (the one directly before onClick) needs the argument.
_lm = 'app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/library/LibraryMixScreen.kt'
try:
    _src = open(_lm).read()
    _new = re.sub(
        r'(interactionSource = interactionSource,\n)(\s*)(onClick = onClick,)',
        r'\1\2indication = null,\n\2\3',
        _src,
    )
    if _new != _src:
        open(_lm, 'w').write(_new)
except FileNotFoundError:
    pass


# compose 1.7's material3 SliderState.onValueChange setter is internal, so upstream's
# post-construction `sliderState.onValueChange = { ... }` cannot compile. The port's
# rememberSliderState ignores it anyway, so the assignment is dropped.
_pref = 'app/src/main/kotlin/moe/rukamori/archivetune/ui/component/Preference.kt'
try:
    _src = open(_pref).read()
    _new = re.sub(
        r'\n(\s*)[A-Za-z]*State\.onValueChange = \{(?:[^{}]|\{[^{}]*\})*\}',
        lambda m: '\n' + m.group(1) + '// SliderState.onValueChange is internal in compose 1.7',
        _src,
    )
    if _new != _src:
        open(_pref, 'w').write(_new)
except FileNotFoundError:
    pass

for file in glob.glob('app/src/main/kotlin/moe/rukamori/archivetune/**/*.kt', recursive=True):
    with open(file, 'r') as f:
        content = f.read()
    if 'MaterialExpressiveTheme' in content:
        content = content.replace('MaterialExpressiveTheme.', 'MaterialTheme.')
        content = content.replace('import androidx.compose.material3.MaterialExpressiveTheme', 'import androidx.compose.material3.MaterialTheme')
        with open(file, 'w') as f:
            f.write(content)

# Create CompositionLocals.kt to restore the composition locals from deleted MainActivity.kt
import os
os.makedirs('app/src/main/kotlin/moe/rukamori/archivetune', exist_ok=True)
with open('app/src/main/kotlin/moe/rukamori/archivetune/CompositionLocals.kt', 'w') as f:
    f.write("""package moe.rukamori.archivetune

import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.staticCompositionLocalOf
import moe.rukamori.archivetune.db.InternalDatabase
import moe.rukamori.archivetune.db.MusicDatabase
import moe.rukamori.archivetune.playback.DownloadUtil
import moe.rukamori.archivetune.playback.PlayerConnection
import moe.rukamori.archivetune.utils.SyncUtils

fun <T> allocateDummy(clazz: Class<T>): T {
    return try {
        val unsafeClass = Class.forName("sun.misc.Unsafe")
        val f = unsafeClass.getDeclaredField("theUnsafe").apply { isAccessible = true }
        val unsafe = f.get(null)
        val instance = unsafeClass.getMethod("allocateInstance", Class::class.java).invoke(unsafe, clazz) as T
        for (field in clazz.declaredFields) {
            if (field.name.startsWith("\$\$delegate_") || field.name.startsWith("delegate")) {
                field.isAccessible = true
                if (field.type.isInterface) {
                    val proxy = java.lang.reflect.Proxy.newProxyInstance(
                        clazz.classLoader,
                        arrayOf(field.type)
                    ) { _, method, _ ->
                        val returnType = method.returnType
                        if (returnType.name == "kotlinx.coroutines.flow.Flow") {
                            kotlinx.coroutines.flow.emptyFlow<Any>()
                        } else if (returnType.name == "kotlinx.coroutines.flow.StateFlow") {
                            kotlinx.coroutines.flow.MutableStateFlow<Any?>(null)
                        } else if (returnType == Boolean::class.java || returnType == Boolean::class.javaPrimitiveType) {
                            false
                        } else if (returnType == Int::class.java || returnType == Int::class.javaPrimitiveType) {
                            0
                        } else {
                            null
                        }
                    }
                    field.set(instance, proxy)
                }
            }
        }
        instance
    } catch (e: Exception) {
        throw RuntimeException(e)
    }
}

val LocalDatabase = staticCompositionLocalOf<MusicDatabase> { InternalDatabase.newInstance(android.content.DummyContext()) }
val LocalPlayerConnection = staticCompositionLocalOf<PlayerConnection?> { null }
val LocalPlayerAwareWindowInsets = compositionLocalOf<WindowInsets> { WindowInsets(0, 0, 0, 0) }
val LocalDownloadUtil = staticCompositionLocalOf<DownloadUtil> { allocateDummy(DownloadUtil::class.java) }
val LocalSyncUtils = staticCompositionLocalOf<SyncUtils> { allocateDummy(SyncUtils::class.java) }
""")

# Material3-expressive members that upstream Android's material3 has as *members* of
# the various *Defaults singletons, but which the desktop port supplies as extension
# functions in android-stubs (it cannot add members to the real classes). Callers in
# upstream code reference them without an import, so add the import where needed.
EXTENSION_IMPORTS = [
    ('ListItemDefaults.segmentedShapes(', 'androidx.compose.material3.segmentedShapes'),
    ('ListItemDefaults.segmentedColors(', 'androidx.compose.material3.segmentedColors'),
    ('ListItemDefaults.SegmentedGap', 'androidx.compose.material3.SegmentedGap'),
    ('ListItemDefaults.shapes(', 'androidx.compose.material3.shapes'),
    ('IconButtonDefaults.shapes(', 'androidx.compose.material3.shapes'),
    ('ButtonDefaults.shapes(', 'androidx.compose.material3.shapes'),
    ('maskClip(', 'androidx.compose.ui.draw.maskClip'),
    ('maskBorder(', 'androidx.compose.ui.draw.maskBorder'),
    ('standardFloatingToolbarColors(', 'androidx.compose.material3.standardFloatingToolbarColors'),
    ('ButtonDefaults.squareShape', 'androidx.compose.material3.squareShape'),
    ('PullToRefreshDefaults.LoadingIndicator', 'androidx.compose.material3.pulltorefresh.LoadingIndicator'),
    ('upstream.uri', 'androidx.media3.datasource.uri'),
    ('upstream.responseHeaders', 'androidx.media3.datasource.responseHeaders'),
    ('ButtonDefaults.SmallContentPadding', 'androidx.compose.material3.SmallContentPadding'),
    ('ButtonDefaults.MediumContentPadding', 'androidx.compose.material3.MediumContentPadding'),
    ('ButtonDefaults.LargeContentPadding', 'androidx.compose.material3.LargeContentPadding'),
    ('ButtonDefaults.MediumContainerHeight', 'androidx.compose.material3.MediumContainerHeight'),
    ('ButtonDefaults.LargeContainerHeight', 'androidx.compose.material3.LargeContainerHeight'),
    ('ButtonDefaults.SmallContainerHeight', 'androidx.compose.material3.SmallContainerHeight'),
    ('ButtonDefaults.contentPaddingFor(', 'androidx.compose.material3.contentPaddingFor'),
    ('ButtonDefaults.iconSizeFor(', 'androidx.compose.material3.iconSizeFor'),
    ('ButtonDefaults.iconSpacingFor(', 'androidx.compose.material3.iconSpacingFor'),
    ('ButtonDefaults.textStyleFor(', 'androidx.compose.material3.textStyleFor'),
    ('FilterChipDefaults.shapes(', 'androidx.compose.material3.shapes'),
    ('MaterialTheme.motionScheme', 'androidx.compose.material3.motionScheme'),
    ('titleLargeEmphasized', 'androidx.compose.material3.titleLargeEmphasized'),
    ('titleMediumEmphasized', 'androidx.compose.material3.titleMediumEmphasized'),
    ('labelLargeEmphasized', 'androidx.compose.material3.labelLargeEmphasized'),
    ('labelMediumEmphasized', 'androidx.compose.material3.labelMediumEmphasized'),
    ('bodyLargeEmphasized', 'androidx.compose.material3.bodyLargeEmphasized'),
    ('bodyMediumEmphasized', 'androidx.compose.material3.bodyMediumEmphasized'),
    ('headlineSmallEmphasized', 'androidx.compose.material3.headlineSmallEmphasized'),
    ('writeTimeout(', 'okhttp3.writeTimeout'),
    ('retryOnConnectionFailure(', 'okhttp3.retryOnConnectionFailure'),
    ('cache.uid', 'androidx.media3.datasource.cache.uid'),
    ('cache.keys', 'androidx.media3.datasource.cache.keys'),
    ('cache.cacheSpace', 'androidx.media3.datasource.cache.cacheSpace'),
]

for path in glob.glob('app/src/main/kotlin/moe/rukamori/archivetune/**/*.kt', recursive=True):
    with open(path, 'r') as f:
        content = f.read()
    needed = sorted({
        imp for marker, imp in EXTENSION_IMPORTS
        if marker in content and ('import %s\n' % imp) not in content
    })
    if not needed:
        continue
    lines = content.split('\n')
    imports = [i for i, l in enumerate(lines) if l.startswith('import ')]
    if not imports:
        continue
    at = imports[-1] + 1
    lines[at:at] = ['import %s' % imp for imp in needed]
    with open(path, 'w') as f:
        f.write('\n'.join(lines))

# Kotlin cannot import a *companion object* member through the enclosing class name
# (`import Foo.CONST`), only through the companion (`import Foo.Companion.CONST`).
# media3/glance are Java upstream, so upstream's `import Foo.CONST` lines are valid
# there; android-stubs reimplements them as Kotlin, so rewrite the imports.
COMPANION_IMPORT = re.compile(
    r'^import ((?:androidx\.media3|androidx\.glance|com\.materialkolor)'
    # The segment before the member must be a CLASS (upper-case initial), not a package:
    # requiring that keeps `pkg.compose.SURFACE_TYPE_TEXTURE_VIEW` (a top-level const)
    # from being rewritten into the non-existent `pkg.compose.Companion.SURFACE_TYPE_TEXTURE_VIEW`.
    r'\.[A-Za-z0-9_.]*?\.[A-Z][A-Za-z0-9_]*)\.([A-Z][A-Z0-9_]{2,})$',
    re.MULTILINE,
)

for path in glob.glob('app/src/main/kotlin/moe/rukamori/archivetune/**/*.kt', recursive=True):
    with open(path, 'r') as f:
        content = f.read()
    rewritten = COMPANION_IMPORT.sub(r'import \1.Companion.\2', content)
    if rewritten != content:
        with open(path, 'w') as f:
            f.write(rewritten)


import pathlib
stringext_path = pathlib.Path('app/src/main/kotlin/moe/rukamori/archivetune/extensions/StringExt.kt')
stringext_content = stringext_path.read_text()
stringext_content = stringext_content.replace('fun String.toSQLiteQuery(): SimpleSQLiteQuery = SimpleSQLiteQuery(this)', 'fun String.toSQLiteQuery(): RoomRawQuery = RoomRawQuery(this)')
stringext_path.write_text(stringext_content)
stringext_content = stringext_path.read_text()
stringext_content = stringext_content.replace('import androidx.sqlite.db.SimpleSQLiteQuery', 'import androidx.room.RoomRawQuery')
stringext_path.write_text(stringext_content)

# Room's KMP runtime has no SupportSQLiteOpenHelper, so MusicDatabase no longer exposes
# `openHelper`. BackupArchiveRepository only used it to hold a transaction open around the raw
# file copy of the database (+ -wal); the WAL checkpoint is already forced by the preceding
# `database.checkpoint()`, so drop the helper transaction wrapper and keep the copy logic.
backup_path = pathlib.Path('app/src/main/kotlin/moe/rukamori/archivetune/backup/BackupArchiveRepository.kt')
backup_content = backup_path.read_text()
backup_content = re.sub(
    r'[ \t]*val connection = database\.openHelper\.writableDatabase\n'
    r'[ \t]*connection\.beginTransactionNonExclusive\(\)\n'
    r'[ \t]*try \{\n',
    '                        run {\n',
    backup_content,
    count=1,
)
backup_content = re.sub(
    r'[ \t]*\} finally \{\n'
    r'[ \t]*connection\.endTransaction\(\)\n'
    r'[ \t]*\}\n',
    '                        }\n',
    backup_content,
    count=1,
)
backup_path.write_text(backup_content)
