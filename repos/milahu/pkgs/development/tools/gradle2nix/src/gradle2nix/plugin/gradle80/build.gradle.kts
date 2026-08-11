plugins {
    `plugin-conventions`
}

dependencies {
    compileOnly(libs.gradle.api.get80())
    implementation(project(":plugin:gradle8"))
}

tasks.shadowJar {
    archiveFileName = "plugin-gradle80.jar"
}
