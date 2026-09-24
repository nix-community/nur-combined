package moe.rukamori.archivetune

import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import moe.rukamori.archivetune.ui.screens.HomeScreen

fun main() = application {
    Window(
        onCloseRequest = ::exitApplication,
        title = "ArchiveTune Desktop"
    ) {
        HomeScreen()
    }
}
