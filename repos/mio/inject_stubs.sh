#!/bin/bash
awk '/rm -rf app\/src\/main\/kotlin\/moe\/rukamori\/archivetune\/aod/ {
    print
    print "    cat > app/src/main/kotlin/moe/rukamori/archivetune/MainActivityStubs.kt << \"EOF\""
    print "    package moe.rukamori.archivetune"
    print "    import androidx.compose.foundation.layout.WindowInsets"
    print "    import androidx.compose.runtime.compositionLocalOf"
    print "    import moe.rukamori.archivetune.db.MusicDatabase"
    print "    import moe.rukamori.archivetune.playback.PlayerConnection"
    print "    import moe.rukamori.archivetune.playback.DownloadUtil"
    print "    import moe.rukamori.archivetune.utils.SyncUtils"
    print "    val LocalDatabase = compositionLocalOf<MusicDatabase> { error(\"Stub\") }"
    print "    val LocalPlayerConnection = compositionLocalOf<PlayerConnection?> { error(\"Stub\") }"
    print "    val LocalPlayerAwareWindowInsets = compositionLocalOf<WindowInsets> { error(\"Stub\") }"
    print "    val LocalDownloadUtil = compositionLocalOf<DownloadUtil> { error(\"Stub\") }"
    print "    val LocalSyncUtils = compositionLocalOf<SyncUtils> { error(\"Stub\") }"
    print "    EOF"
    next
}
{ print }' by-name/ar/archivetune/package.nix > package_temp.nix
mv package_temp.nix by-name/ar/archivetune/package.nix
