{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "terrain";
  version = "1.2.2";
  src = fetchFromGitHub {
    owner = "aaronaanderson";
    repo = "Terrain";
    rev = finalAttrs.version;
    hash = "sha256-1KlM2zTWSWpFqS/bZyW10OZgPkKiRu8UbX8pZ9Eyx7U=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ juceCmakeHook ];

  NIX_CFLAGS_COMPILE = [ "-Wno-error" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open Source Wave Terrain Synth";
    homepage = "https://github.com/aaronaanderson/Terrain";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Terrain";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
