{ lib, stdenv, fetchFromGitLab, pkg-config, dbus, xorg }:

stdenv.mkDerivation rec {
  pname = "lbm";
  version = "2022-03-13";

  src = fetchFromGitLab {
    domain = "git.weitnahbei.de";
    owner = "nullmark";
    repo = "little_blue_man";
    rev = "d8dcd643a02ab7fafe6c6ac88e2e31ee66839a0b";
    hash = "sha256-64lBcpcapT+swVGA/wMAg26eITxtfaGNVGJoH+f05GY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ dbus xorg.libX11 xorg.libXft xorg.libXinerama ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A simple Bluetooth manager";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
