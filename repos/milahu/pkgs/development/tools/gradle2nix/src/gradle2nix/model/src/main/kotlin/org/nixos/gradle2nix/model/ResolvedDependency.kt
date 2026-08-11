package org.nixos.gradle2nix.model

import java.io.Serializable

interface ResolvedDependency : Serializable {
    val coordinates: DependencyCoordinates
    val artifacts: List<ResolvedArtifact>
}
