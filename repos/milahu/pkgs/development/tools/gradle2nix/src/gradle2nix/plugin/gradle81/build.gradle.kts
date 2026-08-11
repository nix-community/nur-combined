plugins {
    `plugin-conventions`
}

dependencies {
    compileOnly(libs.gradle.api.get81())
    implementation(project(":plugin:gradle8"))
}

tasks.shadowJar {
    archiveFileName = "plugin-gradle81.jar"
}
