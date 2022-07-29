{ lib, stdenv, fetchFromGitHub, fontconfig, imlib2, libXft, conf ? null }:

stdenv.mkDerivation rec {
  pname = "mage";
  version = "2022-07-12";

  src = fetchFromGitHub {
    owner = "explosion-mental";
    repo = "mage";
    rev = "6349749dc18deda13e4ac6b7ce0ade8ccb896512";
    hash = "sha256-mLCK38Jm1vVVIYz/e+PJs0qAI3ojmcqmA1+ahiQ6Hk8=";
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
