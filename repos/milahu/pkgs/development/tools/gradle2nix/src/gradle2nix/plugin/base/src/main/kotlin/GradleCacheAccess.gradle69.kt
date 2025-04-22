package org.nixos.gradle2nix

import org.gradle.api.internal.artifacts.ivyservice.ArtifactCachesProvider
import org.gradle.api.invocation.Gradle

object GradleCacheAccessFactoryBase : GradleCacheAccessFactory {
    override fun create(gradle: Gradle): GradleCacheAccess = GradleCacheAccessBase(gradle)
}

class GradleCacheAccessBase(
    gradle: Gradle,
) : GradleCacheAccess {
    private val artifactCachesProvider = gradle.service<ArtifactCachesProvider>()

    override fun useCache(block: () -> Unit) {
        artifactCachesProvider.writableCacheLockingManager.useCache(block)
    }
}
