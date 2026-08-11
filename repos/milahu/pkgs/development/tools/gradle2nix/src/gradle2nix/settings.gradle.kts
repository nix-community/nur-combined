@file:Suppress("UnstableApiUsage")

dependencyResolutionManagement {
    repositories {
        mavenCentral()
        maven { url = uri("https://repo.gradle.org/gradle/libs-releases") }
    }
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
}

include(
    ":app",
    ":model",
    ":plugin:base",
    ":plugin:common",
    ":plugin:gradle75",
    ":plugin:gradle8",
    ":plugin:gradle80",
    ":plugin:gradle81",
)
