{ lib, stdenv, fetchFromGitHub, fontconfig, imlib2, libXft, conf ? null }:

stdenv.mkDerivation rec {
  pname = "mage";
  version = "2022-03-15";

  src = fetchFromGitHub {
    owner = "explosion-mental";
    repo = pname;
    rev = "8e5a13ef208eb2867fda1d62d227dc6c48f25cfd";
    hash = "sha256-5/q4EPl915V1CLkY/WGcWlt5PO27KPk6gapNcOemWO0=";
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
