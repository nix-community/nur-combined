package org.nixos.gradle2nix

import org.gradle.api.invocation.Gradle

fun interface GradleCacheAccessFactory {
    fun create(gradle: Gradle): GradleCacheAccess
}

interface GradleCacheAccess {
    fun useCache(block: () -> Unit)
}
