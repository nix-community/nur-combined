import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.dsl.KotlinVersion

plugins {
    id("org.jetbrains.kotlin.jvm")
}

dependencies {
    compileOnly(kotlin("stdlib"))
}

java {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}

kotlin.compilerOptions {
    @Suppress("DEPRECATION") // we can't use api version greater than 1.4 as minimal supported Gradle version uses kotlin-stdlib 1.4
    apiVersion.set(KotlinVersion.KOTLIN_1_4)
    @Suppress("DEPRECATION") // we can't use language version greater than 1.5 as minimal supported Gradle embeds Kotlin 1.4
    languageVersion.set(KotlinVersion.KOTLIN_1_5)
    jvmTarget.set(JvmTarget.JVM_1_8)
    optIn.add("kotlin.RequiresOptIn")
    freeCompilerArgs.addAll(
        listOf(
            "-Xconsistent-data-class-copy-visibility",
            "-Xskip-prerelease-check",
            "-Xsuppress-version-warnings",
            // We have to override the default value for `-Xsam-conversions` to `class`
            // otherwise the compiler would compile lambdas using invokedynamic,
            // such lambdas are not serializable so are not compatible with Gradle configuration cache.
            // It doesn't lead to a significant difference in binaries sizes, and previously (before LV 1.5) the `class` value was set by default.
            "-Xsam-conversions=class",
        ),
    )
}
