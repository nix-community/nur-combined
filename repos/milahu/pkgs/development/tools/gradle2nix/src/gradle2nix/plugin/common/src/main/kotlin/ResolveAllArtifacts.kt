package org.nixos.gradle2nix

import org.gradle.api.DefaultTask
import org.gradle.api.Project
import org.gradle.api.artifacts.Configuration
import org.gradle.api.artifacts.component.ModuleComponentIdentifier
import org.gradle.api.file.FileCollection
import org.gradle.api.invocation.Gradle
import org.gradle.api.logging.Logging
import org.gradle.api.model.ObjectFactory
import org.gradle.api.tasks.InputFiles
import org.gradle.api.tasks.Internal
import org.gradle.api.tasks.TaskAction
import org.gradle.internal.deprecation.DeprecatableConfiguration
import org.nixos.gradle2nix.model.ARTIFACTS_PROPERTY
import org.nixos.gradle2nix.model.ArtifactType
import org.nixos.gradle2nix.model.RESOLVE_ALL_TASK
import org.nixos.gradle2nix.model.RESOLVE_PROJECT_TASK
import javax.inject.Inject

fun interface ResolveAllArtifactsApplier {
    fun apply(gradle: Gradle)
}

val Project.reportableConfigurations: List<Configuration>
    get() = configurations.filter { (it as? DeprecatableConfiguration)?.canSafelyBeResolved() ?: it.isCanBeResolved }

abstract class AbstractResolveAllArtifactsApplier : ResolveAllArtifactsApplier {
    abstract fun Project.addConfigurationArtifactResolver(
        configuration: Configuration,
        artifactType: ArtifactType,
    ): FileCollection

    final override fun apply(gradle: Gradle) {
        val resolveAll = gradle.rootProject.tasks.register(RESOLVE_ALL_TASK)

        val artifacts =
            System
                .getProperty(ARTIFACTS_PROPERTY, "")
                .split(",")
                .filter { it.isNotBlank() }
                .mapTo(mutableSetOf()) { ArtifactType.valueOf(it.toUpperCase()) }

        // Depend on "dependencies" task in all projects
        gradle.allprojects { project ->
            val resolveProject =
                project.tasks.register(RESOLVE_PROJECT_TASK, ResolveProjectDependenciesTask::class.java) { task ->
                    task.projectName.set(project.path)
                    for (configuration in project.reportableConfigurations) {
                        task.configurations.from(
                            configuration.incoming.artifactView { view ->
                                view.isLenient = true
                                view.componentFilter { it is ModuleComponentIdentifier }
                            }.files
                        )
                        for (artifactType in artifacts) {
                            task.configurations.from(project.addConfigurationArtifactResolver(configuration, artifactType))
                        }
                    }
                }

            resolveAll.configure { it.dependsOn(resolveProject) }
        }

        // Depend on all 'resolveBuildDependencies' task in each included build
        gradle.includedBuilds.forEach { includedBuild ->
            resolveAll.configure {
                it.dependsOn(includedBuild.task(":$RESOLVE_ALL_TASK"))
            }
        }
    }
}

@Suppress("UnstableApiUsage")
abstract class ResolveProjectDependenciesTask
    @Inject
    constructor(
        objects: ObjectFactory,
    ) : DefaultTask() {
        @get:Internal
        val projectName = objects.property(String::class.java)

        @get:InputFiles
        val configurations = objects.fileCollection()

        @TaskAction
        fun resolve() {
            val count = configurations.count()
            LOGGER.info("${projectName.get()}: resolved $count artifacts")
        }

        companion object {
            private val LOGGER = Logging.getLogger(ResolveProjectDependenciesTask::class.java)
        }
    }
