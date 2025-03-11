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
    rev = "036024bf5ffcd14174588bf183f34959e4fda688";
    hash = "sha256-nNCHfMeFTHKm4PbLUbgEFU0/VT0ocaW00uYUs8EnsDQ=";
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
