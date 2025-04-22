package org.nixos.gradle2nix

import org.gradle.api.Project
import org.gradle.api.artifacts.Configuration
import org.gradle.api.artifacts.component.ModuleComponentIdentifier
import org.gradle.api.attributes.Bundling
import org.gradle.api.attributes.Category
import org.gradle.api.attributes.DocsType
import org.gradle.api.attributes.Usage
import org.gradle.api.file.FileCollection
import org.nixos.gradle2nix.model.ArtifactType

private fun Configuration.artifactConfigurationName(artifactType: ArtifactType): String =
    "$name-${artifactType.name.toLowerCase()}-artifacts"

object ResolveAllArtifactsApplierBase : AbstractResolveAllArtifactsApplier() {
    @Suppress("UnstableApiUsage")
    override fun Project.addConfigurationArtifactResolver(
        configuration: Configuration,
        artifactType: ArtifactType,
    ): FileCollection {
        val artifactConfiguration =
            configurations.register(configuration.artifactConfigurationName(artifactType)) { artifactConfig ->
                val usage = configuration.attributes.getAttribute(Usage.USAGE_ATTRIBUTE)
                artifactConfig.extendsFrom(configuration)
                artifactConfig.isCanBeConsumed = false
                artifactConfig.attributes { attrs ->
                    with(attrs) {
                        if (usage != null) {
                            attribute(Usage.USAGE_ATTRIBUTE, usage)
                        }
                        attribute(Category.CATEGORY_ATTRIBUTE, objects.named(Category::class.java, Category.DOCUMENTATION))
                        attribute(Bundling.BUNDLING_ATTRIBUTE, objects.named(Bundling::class.java, Bundling.EXTERNAL))
                        attribute(
                            DocsType.DOCS_TYPE_ATTRIBUTE,
                            objects.named(
                                DocsType::class.java,
                                when (artifactType) {
                                    ArtifactType.DOXYGEN -> DocsType.DOXYGEN
                                    ArtifactType.JAVADOC -> DocsType.JAVADOC
                                    ArtifactType.SAMPLES -> DocsType.SAMPLES
                                    ArtifactType.SOURCES -> DocsType.SOURCES
                                    ArtifactType.USERMANUAL -> DocsType.USER_MANUAL
                                },
                            ),
                        )
                    }
                }
            }

        return objects.fileCollection().from(
            artifactConfiguration.map { config ->
                config.incoming
                    .artifactView { view ->
                        view.isLenient = true
                        view.componentFilter { it is ModuleComponentIdentifier }
                    }.files
            },
        )
    }
}
