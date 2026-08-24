{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation {
  pname = "slew-over";
  version = "plugin-unstable-2025-09-12";
  src = fetchFromGitHub {
    owner = "Mrugalla";
    repo = "Slew-Over";
    rev = "c1d8e253931a10acb7c221960dfa760db964cedd";
    hash = "sha256-co/SwY0PLH1zgpk5qI9Y94/M62r+Rr7tNl0XQpKlaeU=";
  };

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "Slew Over.jucer";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Simple slew limiter with oversampling";
    homepage = "https://github.com/Mrugalla/Slew-Over";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
