package org.nixos.gradle2nix

import org.gradle.api.invocation.Gradle
import org.gradle.api.services.BuildService
import org.gradle.api.services.BuildServiceParameters
import org.gradle.internal.build.event.BuildEventListenerRegistryInternal
import org.gradle.internal.operations.BuildOperationDescriptor
import org.gradle.internal.operations.BuildOperationListener
import org.gradle.internal.operations.OperationFinishEvent
import org.gradle.internal.operations.OperationIdentifier
import org.gradle.internal.operations.OperationProgressEvent
import org.gradle.internal.operations.OperationStartEvent

object DependencyExtractorApplierG75 : DependencyExtractorApplier {
    @Suppress("UnstableApiUsage")
    override fun apply(
        gradle: Gradle,
        extractor: DependencyExtractor,
    ) {
        val serviceProvider =
            gradle.sharedServices
                .registerIfAbsent(
                    "nixDependencyExtractor",
                    DependencyExtractorService::class.java,
                ) {}
                .map { service ->
                    service.apply { this.extractor = extractor }
                }

        gradle.service<BuildEventListenerRegistryInternal>().onOperationCompletion(serviceProvider)
    }
}

@Suppress("UnstableApiUsage")
internal abstract class DependencyExtractorService :
    BuildService<BuildServiceParameters.None>,
    BuildOperationListener,
    AutoCloseable {
    var extractor: DependencyExtractor? = null

    override fun started(
        buildOperation: BuildOperationDescriptor,
        startEvent: OperationStartEvent,
    ) {}

    override fun progress(
        operationIdentifier: OperationIdentifier,
        progressEvent: OperationProgressEvent,
    ) {}

    override fun finished(
        buildOperation: BuildOperationDescriptor,
        finishEvent: OperationFinishEvent,
    ) {
        extractor?.finished(buildOperation, finishEvent)
    }

    override fun close() {
        extractor = null
    }
}
