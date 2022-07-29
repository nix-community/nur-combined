{ lib, stdenv, fetchFromGitHub, pkg-config, gtk3 }:

stdenv.mkDerivation rec {
  pname = "dragon";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "mwh";
    repo = "dragon";
    rev = "v${version}";
    hash = "sha256-wqG6idlVvdN+sPwYgWu3UL0la5ssvymZibiak3KeV7M=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ gtk3 ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Drag and drop source/target for X";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
