dependencyResolutionManagement {
    repositories {
        maven {
            url = uri(System.getProperty("org.nixos.gradle2nix.m2"))
            isAllowInsecureProtocol = true
        }
    }
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
}
