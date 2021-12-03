{ lib, stdenv, fetchFromGitHub, fontconfig, imlib2, libXft, conf ? null }:

stdenv.mkDerivation rec {
  pname = "mage";
  version = "2021-12-03";

  src = fetchFromGitHub {
    owner = "explosion-mental";
    repo = pname;
    rev = "5e9c6e0b0d576b70c5764e7b39201e972a2e4eba";
    hash = "sha256-k5LsO+kpK9lNIzNImNaTb6nr54Y5C3MfZy0oYjjgc6s=";
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
