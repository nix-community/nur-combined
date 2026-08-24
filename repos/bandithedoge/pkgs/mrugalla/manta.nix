{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation {
  pname = "manta";
  version = "VST3-unstable-2024-11-02";
  src = fetchFromGitHub {
    owner = "Mrugalla";
    repo = "Manta";
    rev = "57a76552853dc3d49341497cd61257f9ed6e81d0";
    hash = "sha256-Gclqi3u2W1afOXJdlfLCFLZ5Yfb0jy1cAyy427n0wSw=";
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
    description = "Resonator with extra steps";
    homepage = "https://github.com/Mrugalla/Manta";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
