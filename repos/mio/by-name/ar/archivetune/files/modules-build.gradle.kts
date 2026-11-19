plugins {
    kotlin("jvm")
}

kotlin {
    jvmToolchain(21)
}

dependencies {
    // org.json and the Android platform types come from the port's stubs.
    implementation(project(":android-stubs"))
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.11.0")
    implementation("com.squareup.okhttp3:okhttp:5.4.0")
    implementation("io.github.dokar3:quickjs-kt:1.0.18")
    implementation("org.jsoup:jsoup:1.24.1")
}
