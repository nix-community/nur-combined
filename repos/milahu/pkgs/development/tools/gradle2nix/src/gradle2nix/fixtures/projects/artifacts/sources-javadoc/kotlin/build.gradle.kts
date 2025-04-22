plugins {
    java
}

repositories {
    maven {
        url = uri(System.getProperty("org.nixos.gradle2nix.m2"))
        isAllowInsecureProtocol = true
    }
}

dependencies {
    implementation("org.jetbrains:dummy:0.1.2")
}
