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
    rev = "643641e0eb113e7220aca8c8c587319e0ade249d";
    hash = "sha256-92PMzdNkysXarVro7GAxf4NKw+4i8AUMSlCGVdKBDAY=";
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
