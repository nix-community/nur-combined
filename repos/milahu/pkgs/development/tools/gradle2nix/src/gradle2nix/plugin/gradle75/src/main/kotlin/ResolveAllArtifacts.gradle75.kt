package org.nixos.gradle2nix

import org.gradle.api.Project
import org.gradle.api.artifacts.Configuration
import org.gradle.api.artifacts.component.ModuleComponentIdentifier
import org.gradle.api.attributes.Bundling
import org.gradle.api.attributes.DocsType
import org.gradle.api.file.FileCollection
import org.nixos.gradle2nix.model.ArtifactType

object ResolveAllArtifactsApplierG75 : AbstractResolveAllArtifactsApplier() {
    @Suppress("UnstableApiUsage")
    override fun Project.addConfigurationArtifactResolver(
        configuration: Configuration,
        artifactType: ArtifactType,
    ): FileCollection {
        val result =
            configuration.incoming
                .artifactView { view ->
                    view.isLenient = true
                    view.withVariantReselection()
                    view.componentFilter { it is ModuleComponentIdentifier }
                    view.attributes { attrs ->
                        with(attrs) {
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
                }.files

        configuration.incoming.afterResolve { result.files.count() }

        return result
    }
}
