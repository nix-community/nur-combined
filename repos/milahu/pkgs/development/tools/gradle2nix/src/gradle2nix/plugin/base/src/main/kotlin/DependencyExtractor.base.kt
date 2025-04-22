package org.nixos.gradle2nix

import org.gradle.api.invocation.Gradle
import org.gradle.internal.operations.BuildOperationListenerManager

object DependencyExtractorApplierBase : DependencyExtractorApplier {
    override fun apply(
        gradle: Gradle,
        extractor: DependencyExtractor,
    ) {
        val buildOperationListenerManager = gradle.service<BuildOperationListenerManager>()

        buildOperationListenerManager.addListener(extractor)
        gradle.buildFinished {
            buildOperationListenerManager.removeListener(extractor)
        }
    }
}
