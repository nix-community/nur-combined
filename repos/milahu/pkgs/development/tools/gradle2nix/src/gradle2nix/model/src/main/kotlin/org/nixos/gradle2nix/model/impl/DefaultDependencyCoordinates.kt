package org.nixos.gradle2nix.model.impl

import org.nixos.gradle2nix.model.DependencyCoordinates

data class DefaultDependencyCoordinates(
    override val group: String,
    override val artifact: String,
    override val version: String,
    override val timestamp: String? = null,
) : DependencyCoordinates {
    override val timestampedCoordinates: DependencyCoordinates
        get() = DefaultDependencyCoordinates(group, artifact, timestampedVersion)

    override fun toString(): String = id

    companion object {
        fun parse(id: String): DependencyCoordinates {
            val parts = id.split(":")
            return when (parts.size) {
                3 -> DefaultDependencyCoordinates(parts[0], parts[1], parts[2])
                4 -> DefaultDependencyCoordinates(parts[0], parts[1], parts[2], parts[3])
                else -> throw IllegalStateException(
                    "couldn't parse dependency coordinates: '$id'",
                )
            }
        }
    }
}
