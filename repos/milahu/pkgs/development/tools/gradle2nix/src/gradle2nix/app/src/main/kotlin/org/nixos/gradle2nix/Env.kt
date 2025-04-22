package org.nixos.gradle2nix

import kotlinx.serialization.Serializable

typealias Env = Map<String, Map<String, Artifact>>

@Serializable
data class Artifact internal constructor(
    val url: String,
    val hash: String,
)
