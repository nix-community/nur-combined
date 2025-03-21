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
    rev = "8406f1611431f23b761d12d26839636fefe80149";
    hash = "sha256-2vfj+Y3Qvu3p8SjetMKXA89edny0OHLYKKEjKFyY2Zk=";
  };

  setSourceRoot = ''export sourceRoot="$(echo */aulaf87-rgb)"'';
  makeFlags = [
    "PREFIX=${placeholder "out"}" "UDEVDIR=${placeholder "out"}/etc/udev/rules.d" "SYSTEMDDIR=${placeholder "out"}/lib/systemd/system" "MANDIR=${placeholder "out"}/share/man/man8"
  ];

  meta = {
    description = "Control of Aula F87 keyboard leds";
    homepage = "https://gitlab.com/dukzcry/crap/tree/master/aulaf87-rgb";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "aulaf87-rgb";
    platforms = lib.platforms.linux;
  };
}
