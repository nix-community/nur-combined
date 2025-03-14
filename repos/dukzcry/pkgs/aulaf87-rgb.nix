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
    rev = "77948292754a19ef35c34579a6272e202347aa42";
    hash = "sha256-1bv/7wkiEh1Jgxt2Rf8HOCJyKV0WkbC8+fHS50U8iP0=";
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
