{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "island";
  version = "0-unstable-2026-05-22";

  src = fetchFromGitHub {
    owner = "landlock-lsm";
    repo = "island";
    rev = "05a9d699fbf30289fd2af4311becf38ceb334df2";
    hash = "sha256-H3+BQxUtogcO0LdO8ayHH1aThg6+SZW+++ixelvzUxA=";
  };

  cargoHash = "sha256-0u9emLJmKwZ1EIUIkhl7J32VLNHWNMVfkXY1ocRRp2o=";

  cargoPatches = [
    ./add-Cargo-lock.patch
    ./nix-paths.patch
  ];

  doCheck = false;

  meta = {
    description = "Sandboxing tool using Landlock for secure command execution";
    homepage = "https://landlock.io";
    downloadPage = "https://github.com/landlock-lsm/island";
    license = lib.licenses.OR [
      lib.licenses.asl20
      lib.licenses.mit
    ];
    platforms = lib.platforms.linux;
    mainProgram = "island";
  };
})
