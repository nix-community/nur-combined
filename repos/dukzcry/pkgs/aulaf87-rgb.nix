{
  lib,
  stdenv,
  fetchFromGitLab,
}:

stdenv.mkDerivation rec {
  pname = "aulaf87-rgb";
  version = "unstable-2025-03-11";

  src = fetchFromGitLab {
    owner = "dukzcry";
    repo = "crap";
    rev = "f7a498d6766666e6e70acc539e0c9b5a6520ea56";
    hash = "sha256-QLE4hoo0nHiXpAGpxQuZMuBTZjNF8QLeEC5h0jCPFZY=";
  };

  setSourceRoot = ''export sourceRoot="$(echo */aulaf87-rgb)"'';
  makeFlags = [
    "PREFIX=${placeholder "out"}" "UDEVDIR=${placeholder "out"}/etc/udev/rules.d" "SYSTEMDDIR=${placeholder "out"}/lib/systemd/system"
  ];

  meta = {
    description = "Control Aula F87 Pro LEDs";
    homepage = "https://gitlab.com/dukzcry/crap";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "aulaf87-rgb";
    platforms = lib.platforms.all;
  };
}
