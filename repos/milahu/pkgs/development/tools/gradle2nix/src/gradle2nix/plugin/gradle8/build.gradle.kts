plugins {
    `gradle-kotlin-conventions`
}

dependencies {
    compileOnly(libs.gradle.api.get80())
    api(project(":plugin:common"))
}
