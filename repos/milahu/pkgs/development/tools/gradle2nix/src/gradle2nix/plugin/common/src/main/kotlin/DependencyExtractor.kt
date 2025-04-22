package org.nixos.gradle2nix

import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.decodeFromStream
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import org.gradle.api.internal.artifacts.ivyservice.modulecache.FileStoreAndIndexProvider
import org.gradle.api.invocation.Gradle
import org.gradle.internal.hash.ChecksumService
import org.gradle.internal.operations.BuildOperationDescriptor
import org.gradle.internal.operations.BuildOperationListener
import org.gradle.internal.operations.OperationFinishEvent
import org.gradle.internal.operations.OperationIdentifier
import org.gradle.internal.operations.OperationProgressEvent
import org.gradle.internal.operations.OperationStartEvent
import org.gradle.internal.resource.ExternalResourceReadBuildOperationType
import org.gradle.internal.resource.ExternalResourceReadMetadataBuildOperationType
import org.nixos.gradle2nix.model.DependencyCoordinates
import org.nixos.gradle2nix.model.DependencySet
import org.nixos.gradle2nix.model.impl.DefaultDependencyCoordinates
import org.nixos.gradle2nix.model.impl.DefaultDependencySet
import org.nixos.gradle2nix.model.impl.DefaultResolvedArtifact
import org.nixos.gradle2nix.model.impl.DefaultResolvedDependency
import java.io.File
import java.util.concurrent.ConcurrentHashMap

interface DependencyExtractorApplier {
    fun apply(
        gradle: Gradle,
        extractor: DependencyExtractor,
    )
}

class DependencyExtractor : BuildOperationListener {
    private val urls = ConcurrentHashMap<String, Unit>()

    override fun started(
        buildOperation: BuildOperationDescriptor,
        startEvent: OperationStartEvent,
    ) {}

    override fun progress(
        operationIdentifier: OperationIdentifier,
        progressEvent: OperationProgressEvent,
    ) {}

    override fun finished(
        buildOperation: BuildOperationDescriptor,
        finishEvent: OperationFinishEvent,
    ) {
        when (val details = buildOperation.details) {
            is ExternalResourceReadBuildOperationType.Details -> urls.computeIfAbsent(details.location) { Unit }
            is ExternalResourceReadMetadataBuildOperationType.Details -> urls.computeIfAbsent(details.location) { Unit }
            else -> null
        } ?: return
    }

    fun buildDependencySet(
        cacheAccess: GradleCacheAccess,
        checksumService: ChecksumService,
        fileStoreAndIndexProvider: FileStoreAndIndexProvider,
    ): DependencySet {
        val files = mutableMapOf<DependencyCoordinates, MutableMap<File, String>>()
        val mappings = mutableMapOf<DependencyCoordinates, Map<String, String>>()

        cacheAccess.useCache {
            for ((url, _) in urls) {
                fileStoreAndIndexProvider.externalResourceIndex.lookup(url)?.let { cached ->
                    cached.cachedFile?.let { file ->
                        cachedComponentId(file)?.let { componentId ->
                            files.getOrPut(componentId, ::mutableMapOf)[file] = url
                            if (file.extension == "module") {
                                parseFileMappings(file)?.let {
                                    mappings[componentId] = it
                                }
                            }
                        }
                    }
                }
            }
        }

        return DefaultDependencySet(
            dependencies =
                buildList {
                    for ((componentId, componentFiles) in files) {
                        add(
                            DefaultResolvedDependency(
                                componentId,
                                buildList {
                                    val remoteMappings = mappings[componentId]
                                    for ((file, url) in componentFiles) {
                                        add(
                                            DefaultResolvedArtifact(
                                                remoteMappings?.get(file.name) ?: file.name,
                                                checksumService.sha256(file).toString(),
                                                url,
                                            ),
                                        )
                                    }
                                },
                            ),
                        )
                    }
                },
        )
    }
}

private fun <T> buildList(block: MutableList<T>.() -> Unit): List<T> = mutableListOf<T>().apply(block).toList()

private fun cachedComponentId(file: File): DependencyCoordinates? {
    val parts = file.invariantSeparatorsPath.split('/')
    if (parts.size < 6) return null
    if (parts[parts.size - 6] != "files-2.1") return null
    return parts
        .dropLast(2)
        .takeLast(3)
        .joinToString(":")
        .let(DefaultDependencyCoordinates::parse)
}

@OptIn(ExperimentalSerializationApi::class)
private fun parseFileMappings(file: File): Map<String, String>? =
    try {
        Json
            .decodeFromStream<JsonObject>(file.inputStream())
            .jsonObject["variants"]
            ?.jsonArray
            ?.flatMap { it.jsonObject["files"]?.jsonArray ?: emptyList() }
            ?.map { it.jsonObject }
            ?.mapNotNull {
                val name = it["name"]?.jsonPrimitive?.content ?: return@mapNotNull null
                val url = it["url"]?.jsonPrimitive?.content ?: return@mapNotNull null
                if (name != url) name to url else null
            }?.toMap()
            ?.takeUnless { it.isEmpty() }
    } catch (e: Throwable) {
        null
    }
