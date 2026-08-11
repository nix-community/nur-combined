package org.nixos.gradle2nix

import org.gradle.api.Project
import org.gradle.api.internal.artifacts.ivyservice.modulecache.FileStoreAndIndexProvider
import org.gradle.internal.hash.ChecksumService
import org.gradle.tooling.provider.model.ToolingModelBuilder
import org.nixos.gradle2nix.model.DependencySet

class DependencySetModelBuilder(
    private val dependencyExtractor: DependencyExtractor,
    private val cacheAccess: GradleCacheAccess,
    private val checksumService: ChecksumService,
    private val fileStoreAndIndexProvider: FileStoreAndIndexProvider,
) : ToolingModelBuilder {
    override fun canBuild(modelName: String): Boolean = modelName == DependencySet::class.qualifiedName

    override fun buildAll(
        modelName: String,
        project: Project,
    ): DependencySet =
        dependencyExtractor.buildDependencySet(
            cacheAccess,
            checksumService,
            fileStoreAndIndexProvider,
        )
}
