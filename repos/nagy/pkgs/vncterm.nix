{ lib, stdenv, fetchFromGitHub, autoreconfHook, pkg-config, libvncserver }:

stdenv.mkDerivation rec {
  pname = "vncterm";
  version = "0.9.10";

  src = fetchFromGitHub {
    owner = "LibVNC";
    repo = pname;
    rev = version;
    sha256 = "sha256-6Lk9b4qi3jpJOxX578Jkq/zZ9N4Xmu2XL1Vsbs2goig=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [ libvncserver ];

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "Export virtual console sessions to any VNC client";
    license = licenses.gpl2;
    platforms = platforms.linux;
    mainProgram = "linuxvnc";
  };
}
