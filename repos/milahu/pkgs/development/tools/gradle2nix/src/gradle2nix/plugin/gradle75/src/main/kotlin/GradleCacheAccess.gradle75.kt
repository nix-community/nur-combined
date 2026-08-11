package org.nixos.gradle2nix

import org.gradle.api.internal.artifacts.ivyservice.ArtifactCachesProvider
import org.gradle.api.invocation.Gradle

object GradleCacheAccessFactoryG75 : GradleCacheAccessFactory {
    override fun create(gradle: Gradle): GradleCacheAccess = GradleCacheAccessG75(gradle)
}

class GradleCacheAccessG75(
    gradle: Gradle,
) : GradleCacheAccess {
    private val artifactCachesProvider = gradle.service<ArtifactCachesProvider>()

    override fun useCache(block: () -> Unit) {
        artifactCachesProvider.writableCacheLockingManager.useCache(block)
    }
}
