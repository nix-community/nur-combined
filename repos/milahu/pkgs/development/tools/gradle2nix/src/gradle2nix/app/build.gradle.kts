import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("org.jetbrains.kotlin.jvm")
    id("org.jetbrains.kotlin.plugin.serialization")
    application
}

configurations.register("share")

dependencies {
    implementation(project(":model"))
    implementation(libs.clikt)
    implementation(libs.gradle.toolingApi)
    implementation(libs.kotlin.stdlib)
    implementation(libs.kotlinx.coroutines.core)
    implementation(libs.serialization.json)
    runtimeOnly(libs.slf4j.simple)

    "share"(project(":plugin:base", configuration = "shadow"))
    "share"(project(":plugin:gradle80", configuration = "shadow"))
    "share"(project(":plugin:gradle81", configuration = "shadow"))

    testImplementation(libs.kotest.assertions)
    testImplementation(libs.kotest.runner)
    testImplementation(libs.ktor.server.core)
    testImplementation(libs.ktor.server.netty)
}

application {
    mainClass.set("org.nixos.gradle2nix.MainKt")
    applicationName = "gradle2nix"
    applicationDefaultJvmArgs =
        listOf(
            "-Dorg.nixos.gradle2nix.share=@APP_HOME@/share",
            "-Dslf4j.internal.verbosity=ERROR",
        )
    applicationDistribution
        .from(configurations.named("share"))
        .into("share")
}

java {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_1_8)
        optIn.add("kotlin.RequiresOptIn")
        freeCompilerArgs.addAll(
            "-Xconsistent-data-class-copy-visibility"
        )
    }
}

sourceSets {
    test {
        resources {
            srcDir("$rootDir/fixtures")
        }
    }
}

val updateGolden = providers.gradleProperty("update-golden")

tasks {
    (run) {
        enabled = false
    }

    startScripts {
        doLast {
            unixScript.writeText(
                unixScript.readText().replace("@APP_HOME@", "'\$APP_HOME'"),
            )
            windowsScript.writeText(
                windowsScript.readText().replace("@APP_HOME@", "%APP_HOME%"),
            )
        }
    }

    // TODO Find out why this fails the configuration cache
    test {
        notCompatibleWithConfigurationCache("contains a Task reference")
        dependsOn(installDist)
        val shareDir = layout.dir(installDist.map { it.destinationDir.resolve("share") })
        doFirst {
            if (updateGolden.isPresent) {
                systemProperty("org.nixos.gradle2nix.update-golden", "")
            }
            systemProperties(
                "org.nixos.gradle2nix.share" to shareDir.get().asFile,
                "org.nixos.gradle2nix.m2" to "http://0.0.0.0:8989/m2",
            )
        }
        useJUnitPlatform()
        testLogging {
            events("passed", "skipped", "failed")
        }
    }
}
