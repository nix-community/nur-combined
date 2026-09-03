{
  stdenv,
  fetchgit,
  callPackage,
  writeShellScript,
  nix-update-script,
  zig_0_16,
  pkg-config,
  wayland,
  wayland-scanner,
  wayland-protocols,
  libxkbcommon,
  jq,
  lib,
}:

stdenv.mkDerivation (final: {
  pname = "kwim-nightly";
  version = "0.2.0";

  src = fetchgit { # for some reason, fetchFromGitHub pulls older commit tree
    url = "https://github.com/kewuaa/kwim.git";
    rev = "becc1284ccc8c5abdfb8a117b561a97f4448e9dd";
    hash = "sha256-Ob59H1535EYReXMCERdlTNfhwv2GGBCSCmvfIeJzzzo=";
  };

  nativeBuildInputs = [
    zig_0_16
    pkg-config
  ];

  buildInputs = [
    wayland
    wayland-scanner
    wayland-protocols
    libxkbcommon
  ];

  deps = callPackage ./deps.nix { };

  zigBuildFlags = [
    "--system"
    (toString final.deps)
  ];

  passthru.updateScript = writeShellScript "update-my-package" ''
    set -euo pipefail
    export DEPS_PATCH="${toString ./deps.sed-patch}"

    ${./update-deps.sh} ${./deps.nix}

    ${
      nix-update-script {
        extraArgs = [
          "--version"
          "branch=master"
        ];
      }
    } | ${lib.getExe jq} -c '[.[0] as $root | $root + {file: $root.file + ["${./deps.nix}"]}]'
  '';

  meta = {
    description = "An input manager for River";
    license = lib.licenses.gpl3;
    homepage = "https://github.com/kewuaa/kwim#readme";
    mainProgram = "kwim";
  };
})
