
// Nix: do not run Android lint. AGP still needs lint-model and lint-typedef-remover.
subprojects {
    tasks.configureEach {
        if (name.startsWith("lint")) {
            enabled = false
        }
    }
}
