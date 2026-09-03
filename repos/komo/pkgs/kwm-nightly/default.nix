{
  stdenv,
  fetchFromGitHub,
  callPackage,
  writeShellScript,
  nix-update-script,
  zig_0_16,
  pkg-config,
  fcft,
  pixman,
  wayland,
  wayland-scanner,
  wayland-protocols,
  libxkbcommon,
  jq,
  lib,
}:

stdenv.mkDerivation (final: {
  pname = "kwm-nightly";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "kewuaa";
    repo = "kwm";
    rev = "3f966c9c79d4e31f58ea8d012129cda38f8115cc";
    hash = "sha256-k1NsihGCWnJVZXAi2y1F4QZ1GwHBijg6fW3mMq5eMgI=";
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
    fcft
    pixman
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
    
    ${nix-update-script {
      extraArgs = [
        "--version"
        "branch=master"
      ];
    }} | ${lib.getExe jq} -c '[.[0] as $root | $root + {file: $root.file + ["${./deps.nix}"]}]'
  '';

  meta = {
    description = "A window manager based on River Wayland compositor";
    license = lib.licenses.gpl3;
    homepage = "https://github.com/kewuaa/kwm#readme";
    mainProgram = "kwm";
  };
})
