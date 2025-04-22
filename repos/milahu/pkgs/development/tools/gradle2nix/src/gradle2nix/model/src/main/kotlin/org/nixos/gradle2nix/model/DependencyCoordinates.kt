package org.nixos.gradle2nix.model

import java.io.Serializable

interface DependencyCoordinates : Serializable {
    val group: String
    val artifact: String

    /**
     * For normal dependencies, the dependency version (e.g. "2.0.2").
     *
     * For Maven snapshot dependencies, the snapshot version (e.g. "2.0.2-SNAPSHOT").
     */
    val version: String

    /**
     * For Maven snapshot dependencies, the snapshot timestamp (e.g. "20070310.18163-3").
     *
     * For normal dependencies, this is null.
     */
    val timestamp: String?

    val id: String get() =
        if (timestamp != null) {
            "$group:$artifact:$version:$timestamp"
        } else {
            "$group:$artifact:$version"
        }

    val timestampedCoordinates: DependencyCoordinates

    val timestampedVersion: String get() =
        timestamp?.let { version.replace("-SNAPSHOT", "-$it") } ?: version
}
