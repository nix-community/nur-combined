package org.nixos.gradle2nix

import java.io.File

tailrec fun getProjectRoot(path: File): File? {
    return if (path.isProjectRoot()) {
        path
    } else {
        val parent = path.parentFile ?: return null
        return getProjectRoot(parent)
    }
}

fun File.isProjectRoot(): Boolean = isDirectory && (resolve("settings.gradle").isFile || resolve("settings.gradle.kts").isFile)
