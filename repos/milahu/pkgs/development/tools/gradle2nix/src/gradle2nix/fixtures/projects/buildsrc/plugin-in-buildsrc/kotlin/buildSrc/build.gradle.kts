plugins {
    `kotlin-dsl`
}

repositories {
    gradlePluginPortal()
}

dependencies {
    implementation("com.gradle.publish:plugin-publish-plugin:1.2.1")
}

gradlePlugin {
    plugins {
        register("apply-plugin-publish") {
            id = "com.example.apply-plugin-publish"
            implementationClass = "com.example.ApplyPluginPublishPlugin"
        }
    }
}
