plugins {
    `gradle-kotlin-conventions`
}

dependencies {
    compileOnly(libs.gradle.api.get69())
    api(project(":model"))
    implementation(libs.serialization.json)
}
