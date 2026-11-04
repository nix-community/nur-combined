{
  lib,
  fetchFromGitHub,
  fetchpatch,
  rustPlatform,
  llvmPackages,
  pkg-config,
  elfutils,
  zlib,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "landlock-observability";
  version = "0-unstable-2026-10-02";

  src = fetchFromGitHub {
    owner = "landlock-lsm";
    repo = "landlock-observability";
    rev = "23a6e54c9adbda53e89960ab32d03882bc46d20c";
    hash = "sha256-2XRe4yMyo5C3PjhxX+/hzo+L5fEtmV04jt9a6Up01t4=";
  };

  patches = [
    # Linux v7.4 changed things
    (fetchpatch {
      url = "https://github.com/Skyb0rg007/landlock-observability/commit/696b16d1800f65931b0c871bde8dcbcc78c0f5da.patch";
      hash = "sha256-1t66trq8szMbT5ZibE1Y6Y2Mf/EDRfXBE0bt6gYXQWA=";
    })
  ];

  cargoHash = "sha256-t8VJ6yYGfDFL8EnsT4ZUamkTMwzXPcUhte5XvSEZQ0A=";

  nativeBuildInputs = [
    pkg-config
    # The BPF program is built with -Werror, which trips on cc-wrapper flags
    llvmPackages.clang-unwrapped
  ];

  buildInputs = [
    elfutils
    zlib
  ];

  cargoBuildFlags = [ "--package=lltop" ];
  cargoTestFlags = [ "--package=lltop" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Library for observing Landlock";
    homepage = "https://github.com/landlock-lsm/landlock-observability";
    license =
      with lib.licenses;
      AND [
        (OR [
          mit
          asl20
        ])
        gpl2Only
      ];
    mainProgram = "lltop";
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.linux;
  };
})
