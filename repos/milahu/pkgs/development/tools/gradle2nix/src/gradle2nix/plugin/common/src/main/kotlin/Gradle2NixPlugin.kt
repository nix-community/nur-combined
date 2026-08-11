package org.nixos.gradle2nix

import org.gradle.api.Plugin
import org.gradle.api.internal.artifacts.ivyservice.modulecache.FileStoreAndIndexProvider
import org.gradle.api.invocation.Gradle
import org.gradle.internal.hash.ChecksumService
import org.gradle.tooling.provider.model.ToolingModelBuilderRegistry

abstract class AbstractGradle2NixPlugin(
    private val cacheAccessFactory: GradleCacheAccessFactory,
    private val dependencyExtractorApplier: DependencyExtractorApplier,
    private val resolveAllArtifactsApplier: ResolveAllArtifactsApplier,
) : Plugin<Gradle> {
    override fun apply(gradle: Gradle) {
        val extractor = DependencyExtractor()

        gradle.service<ToolingModelBuilderRegistry>().register(
            DependencySetModelBuilder(
                extractor,
                cacheAccessFactory.create(gradle),
                gradle.service<ChecksumService>(),
                gradle.service<FileStoreAndIndexProvider>(),
            ),
        )

        dependencyExtractorApplier.apply(gradle, extractor)

        gradle.projectsEvaluated {
            resolveAllArtifactsApplier.apply(gradle)
        }
    }
}
