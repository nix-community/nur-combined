plugins {
    `plugin-conventions`
}

dependencies {
    implementation(project(":plugin:common"))
    compileOnly(libs.gradle.api.get69())
}

tasks.shadowJar {
    archiveFileName = "plugin-base.jar"
}
