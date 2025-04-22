plugins {
    java
}

repositories {
    maven {
        url = uri(System.getProperty("org.nixos.gradle2nix.m2"))
        println(uri(System.getProperty("org.nixos.gradle2nix.m2")))
        isAllowInsecureProtocol = true
    }
}

dependencies {
    implementation(platform("io.micrometer:micrometer-bom:1.5.1"))
    implementation("io.micrometer:micrometer-core")
}
