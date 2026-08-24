{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation {
  pname = "nel-19";
  version = "plugin-unstable-2024-09-08";
  src = fetchFromGitHub {
    owner = "Mrugalla";
    repo = "NEL-19";
    rev = "eb112420eb8547c419ffd1fe5f66672bb600fe47";
    hash = "sha256-+6C54F57BPplWcu8DN8bCzHP9KFeWcUYTA6Y9MP/qwc=";
  };

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "NEL-19.jucer";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Open-source vibrato plugin with an extensive modulation system";
    homepage = "https://github.com/Mrugalla/NEL-19";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
