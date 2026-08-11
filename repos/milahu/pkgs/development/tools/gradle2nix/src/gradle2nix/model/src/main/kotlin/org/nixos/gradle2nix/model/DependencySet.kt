package org.nixos.gradle2nix.model

import java.io.Serializable

interface DependencySet : Serializable {
    val dependencies: List<ResolvedDependency>
}
