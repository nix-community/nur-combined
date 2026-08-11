package org.nixos.gradle2nix.model.impl

import org.nixos.gradle2nix.model.ResolvedArtifact

data class DefaultResolvedArtifact(
    override val name: String,
    override val hash: String,
    override val url: String,
) : ResolvedArtifact
