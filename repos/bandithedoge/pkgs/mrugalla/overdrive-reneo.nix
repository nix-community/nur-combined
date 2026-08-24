{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation {
  pname = "overdrive-reneo";
  version = "st-unstable-2025-09-15";
  src = fetchFromGitHub {
    owner = "Mrugalla";
    repo = "Overdrive-ReNEO";
    rev = "a7ab76e2915a0e68f2e6946d8389ad6e308643ac";
    hash = "sha256-UjimeLAxXVFKhClAuirM34xLHzL5FbORUuqiUeH9q38=";
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
    description = "mda overdrive tribute project";
    homepage = "https://github.com/Mrugalla/Overdrive-ReNEO";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
