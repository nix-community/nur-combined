{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation {
  pname = "absorb";
  version = "VST3-unstable-2025-09-12";
  src = fetchFromGitHub {
    owner = "Mrugalla";
    repo = "Absorb";
    rev = "dc340430494213db40c67a04e9796b0462e61363";
    hash = "sha256-+nU0+QJ730mVnbqavJCzvTEs1555S0+gYVW+3rhmN2c=";
  };

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "Project.jucer";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Sidechain plugin that mixes up the texture of the colliding input signals";
    homepage = "github.com/Mrugalla/Absorb";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
