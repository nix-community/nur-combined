package org.nixos.gradle2nix

abstract class Gradle2NixPlugin :
    AbstractGradle2NixPlugin(
        GradleCacheAccessFactoryG75,
        DependencyExtractorApplierG75,
        ResolveAllArtifactsApplierG75,
    )
