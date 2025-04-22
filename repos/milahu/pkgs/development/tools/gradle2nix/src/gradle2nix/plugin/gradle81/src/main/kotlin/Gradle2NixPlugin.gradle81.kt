package org.nixos.gradle2nix

abstract class Gradle2NixPlugin :
    AbstractGradle2NixPlugin(
        GradleCacheAccessFactoryG81,
        DependencyExtractorApplierG8,
        ResolveAllArtifactsApplierG8,
    )
