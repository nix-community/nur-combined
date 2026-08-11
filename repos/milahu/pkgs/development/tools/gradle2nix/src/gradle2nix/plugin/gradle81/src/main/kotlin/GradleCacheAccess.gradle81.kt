package org.nixos.gradle2nix

import org.gradle.api.internal.artifacts.ivyservice.ArtifactCachesProvider
import org.gradle.api.invocation.Gradle

object GradleCacheAccessFactoryG81 : GradleCacheAccessFactory {
    override fun create(gradle: Gradle): GradleCacheAccess = GradleCacheAccessG81(gradle)
}

class GradleCacheAccessG81(
    gradle: Gradle,
) : GradleCacheAccess {
    private val artifactCachesProvider = gradle.service<ArtifactCachesProvider>()

    override fun useCache(block: () -> Unit) {
        artifactCachesProvider.writableCacheAccessCoordinator.useCache(block)
    }
}
