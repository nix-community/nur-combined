package org.nixos.gradle2nix.model.impl

import org.nixos.gradle2nix.model.DependencyCoordinates
import org.nixos.gradle2nix.model.ResolvedArtifact
import org.nixos.gradle2nix.model.ResolvedDependency

data class DefaultResolvedDependency(
    override val coordinates: DependencyCoordinates,
    override val artifacts: List<ResolvedArtifact>,
) : ResolvedDependency
