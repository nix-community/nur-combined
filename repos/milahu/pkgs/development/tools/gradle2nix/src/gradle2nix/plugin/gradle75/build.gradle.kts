plugins {
    `plugin-conventions`
}

dependencies {
    compileOnly(libs.gradle.api.get75())
    implementation(project(":plugin:common"))
}

tasks.shadowJar {
    archiveFileName = "plugin-gradle75.jar"
}
