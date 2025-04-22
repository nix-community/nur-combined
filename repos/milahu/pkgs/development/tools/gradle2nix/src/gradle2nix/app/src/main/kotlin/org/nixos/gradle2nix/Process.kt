package org.nixos.gradle2nix

import org.nixos.gradle2nix.model.DependencyCoordinates
import org.nixos.gradle2nix.model.DependencySet
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi

fun processDependencies(
    config: Config,
    dependencySets: Iterable<DependencySet>,
): Env =
    buildMap<DependencyCoordinates, Map<String, Artifact>> {
        for (dependencySet in dependencySets) {
            val env = dependencySet.toEnv()

            for ((id, artifacts) in env) {
                merge(id, artifacts) { a, b ->
                    buildMap {
                        putAll(a)
                        for ((name, artifact) in b) {
                            merge(name, artifact) { aa, ba ->
                                check(aa.hash == ba.hash) {
                                    config.logger.error(
                                        """
                                        Conflicting hashes found for $id:$name:
                                          1: ${aa.hash}
                                          2: ${ba.hash}
                                        """.trimIndent(),
                                    )
                                }

                                aa
                            }
                        }
                    }
                }
            }
        }
    }.mapValues { (_, artifacts) ->
        artifacts.toSortedMap()
    }.toSortedMap(coordinatesComparator)
        .mapKeys { (coordinates, _) -> coordinates.id }

private fun DependencySet.toEnv(): Map<DependencyCoordinates, Map<String, Artifact>> =
    dependencies.associate { dep ->
        dep.coordinates to
            dep.artifacts.associate {
                it.name to Artifact(it.url, it.hash.toSri())
            }
    }

@OptIn(ExperimentalEncodingApi::class, ExperimentalStdlibApi::class)
internal fun String.toSri(): String =
    buildString {
        append("sha256-")
        Base64.encodeToAppendable(hexToByteArray(), this)
    }

private val coordinatesComparator: Comparator<DependencyCoordinates> =
    compareBy<DependencyCoordinates> { it.group }
        .thenBy { it.artifact }
        .thenByDescending { Version(it.version) }
        .thenByDescending { it.timestamp }
