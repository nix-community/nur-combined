package org.nixos.gradle2nix

import org.gradle.api.internal.artifacts.ivyservice.ArtifactCachesProvider
import org.gradle.api.invocation.Gradle

object GradleCacheAccessFactoryG80 : GradleCacheAccessFactory {
    override fun create(gradle: Gradle): GradleCacheAccess = GradleCacheAccessG80(gradle)
}

class GradleCacheAccessG80(
    gradle: Gradle,
) : GradleCacheAccess {
    private val artifactCachesProvider = gradle.service<ArtifactCachesProvider>()

    override fun useCache(block: () -> Unit) {
        artifactCachesProvider.writableCacheLockingManager.useCache(block)
    }
}
