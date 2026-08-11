val kotlinVersion = "1.6.21"
val spekVersion = "2.0.9"

plugins {
    application
    kotlin("jvm") version "1.6.21"
}

dependencies {
    compileOnly(kotlin("stdlib"))
    implementation("com.natpryce:konfig:1.6.10.0")
    implementation("com.github.pengrad:java-telegram-bot-api:4.6.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.3.3")
    implementation("org.jetbrains.exposed:exposed-core:0.50.1")
    implementation("org.jetbrains.exposed", "exposed-dao", "0.50.1")
    implementation("org.jetbrains.exposed", "exposed-jdbc", "0.50.1")
    implementation("org.jetbrains.exposed", "exposed-jodatime", "0.50.1")
    implementation("io.javalin:javalin:3.7.0")
    implementation("org.slf4j:slf4j-simple:1.8.0-beta4")
    implementation(group = "org.xerial", name = "sqlite-jdbc", version = "3.30.1")
    implementation("org.postgresql:postgresql:42.2.2")
    implementation("com.fasterxml.jackson.core:jackson-databind:2.10.1")
    testImplementation("org.spekframework.spek2:spek-dsl-jvm:$spekVersion")
    testRuntimeOnly("org.spekframework.spek2:spek-runner-junit5:$spekVersion")
    testCompileOnly("com.winterbe:expekt:0.5.0")
}

repositories {
    mavenCentral()
}
