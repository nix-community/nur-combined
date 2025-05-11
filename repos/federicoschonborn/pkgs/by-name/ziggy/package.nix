{
  lib,
  stdenv,
  fetchFromGitHub,
  zig,
  callPackage,
  nix-update-script,
# writeScript,
# zon2nix-unstable,
}:

stdenv.mkDerivation {
  pname = "ziggy";
  version = "0.0.1-unstable-2025-04-18";

  src = fetchFromGitHub {
    owner = "kristoff-it";
    repo = "ziggy";
    rev = "fe3bf9389e7ff213cf3548caaf9c6f3d4bb38647";
    hash = "sha256-w2WO2N3+XJWhWnt9swOux2ynKxmePbB4VojXM8K5GAo=";
  };

  nativeBuildInputs = [
    zig.hook
  ];

  zigDeps = callPackage ./deps.nix { };

  postPatch = ''
    ln -s $zigDeps $ZIG_GLOBAL_CACHE_DIR/p
  '';

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

    # updateDeps = writeScript "update-deps" ''
    #   ${lib.getExe zon2nix-unstable} ${finalAttrs.src} > deps.nix
    # '';
  };

  meta = {
    mainProgram = "ziggy";
    description = "A data serialization language for expressing clear API messages, config files, etc";
    homepage = "https://github.com/kristoff-it/ziggy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder zig.version "0.14";
    inherit (zig.meta) platforms;
  };
}
