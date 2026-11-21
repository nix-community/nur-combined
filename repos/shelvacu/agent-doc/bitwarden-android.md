# bitwarden (android)

`androidPackages/bitwarden`, upstream tags `vYYYY.M.P-bwpm` on bitwarden/android.

## Updating

1. Bump `version`, fix `src.hash`.
2. Gradle: AGP enforces a minimum Gradle version; if nixpkgs `gradle_9` is too old, use
   `gradle-packages.mkGradle` with the version from upstream's `gradle/wrapper/gradle-wrapper.properties`.
3. Regenerate `gradle.lock` from a writable copy of the source, **without** the
   credentials patch (GitHub Packages needs auth for `com.bitwarden:sdk-android`):
   - `GITHUB_TOKEN` needs `read:packages`.
   - `resolveAllArtifacts` runs the Google Services tasks for every variant, so drop
     placeholder `google-services.json` files (copy the debug one, fix `package_name`) into
     `app/src/standardBeta`, `app/src/standardRelease`, `authenticator/src/release`.
     Excluding those tasks with `-x` breaks other tasks instead.
   - Upstream commits Gradle dependency locks; pass `-- --write-locks` to gradle2nix (the
     build also uses it).
   - `nix build .#vacuBuildDerivations.<system>.bitwarden.gradle2nix`, run it from the source dir.
4. The nix FODs for the github packages files 401. Add them from the gradle cache used in
   step 3 (`passthru.addMavenFiles` does this for `~/.gradle/caches`).
5. The build is memory heavy; kill leftover gradle/kotlin daemons from step 3 first.
