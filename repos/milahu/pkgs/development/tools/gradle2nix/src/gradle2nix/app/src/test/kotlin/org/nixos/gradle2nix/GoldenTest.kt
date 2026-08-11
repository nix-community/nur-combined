package org.nixos.gradle2nix

import io.kotest.core.extensions.install
import io.kotest.core.spec.style.FunSpec

class GoldenTest :
    FunSpec({
        install(MavenRepo)

        context("artifacts") {
            golden("artifacts/sources-javadoc", "-a", "sources,javadoc")
        }
        context("basic") {
            golden("basic/basic-java-project")
            golden("basic/basic-kotlin-project")
        }
        context("buildsrc") {
            golden("buildsrc/plugin-in-buildsrc")
        }
        context("dependency") {
            golden("dependency/classifier")
            golden("dependency/maven-bom")
            golden("dependency/snapshot")
            golden("dependency/snapshot-dynamic")
            golden("dependency/snapshot-redirect")
        }
        context("included-build") {
            golden("included-build")
        }
        context("integration") {
            golden("integration/settings-buildscript")
        }
        context("ivy") {
            golden("ivy/basic")
        }
        context("plugin") {
            golden("plugin/resolves-from-default-repo")
        }
        // FIXME Need s3mock or similar to generate golden data.
        xcontext("s3") {
            golden("s3/maven")
            golden("s3/maven-snapshot")
        }
        context("settings") {
            golden("settings/buildscript")
            golden("settings/dependency-resolution-management")
        }
        context("subprojects") {
            golden("subprojects/multi-module")
        }
    })
