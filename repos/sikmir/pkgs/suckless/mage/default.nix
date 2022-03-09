{ lib, stdenv, fetchFromGitHub, fontconfig, imlib2, libXft, conf ? null }:

stdenv.mkDerivation rec {
  pname = "mage";
  version = "2022-02-24";

  src = fetchFromGitHub {
    owner = "explosion-mental";
    repo = pname;
    rev = "c0cd7e6ad6dd9fedf200086e4f9f1521e35f8322";
    hash = "sha256-xdKm1HcHeCy+qRyti/htGcKbCDWNoFp+B0OC3Ln4nuQ=";
  };

  configFile = lib.optionalString (conf!=null) (builtins.toFile "config.h" conf);
  preBuild = lib.optionalString (conf!=null) "cp ${configFile} config.h";

  buildInputs = [ fontconfig imlib2 libXft ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "iMAGE viewer";
    inherit (src.meta) homepage;
    license = licenses.gpl2Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
