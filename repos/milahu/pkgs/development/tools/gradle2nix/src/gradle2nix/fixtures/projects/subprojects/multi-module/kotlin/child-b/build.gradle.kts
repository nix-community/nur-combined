
plugins {
    java
}

dependencies {
    implementation(project(":child-a"))
    implementation("com.squareup.moshi:moshi:1.8.0")
}
