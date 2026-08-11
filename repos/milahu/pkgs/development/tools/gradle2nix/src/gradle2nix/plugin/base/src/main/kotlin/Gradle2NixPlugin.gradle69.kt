package org.nixos.gradle2nix

abstract class Gradle2NixPlugin :
    AbstractGradle2NixPlugin(
        GradleCacheAccessFactoryBase,
        DependencyExtractorApplierBase,
        ResolveAllArtifactsApplierBase,
    )
