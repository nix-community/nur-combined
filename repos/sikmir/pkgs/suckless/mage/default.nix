{ lib, stdenv, fetchFromGitHub, fontconfig, imlib2, libXft, conf ? null }:

stdenv.mkDerivation rec {
  pname = "mage";
  version = "2022-01-24";

  src = fetchFromGitHub {
    owner = "explosion-mental";
    repo = pname;
    rev = "ce5c6cc153aae3e6facac6d60fe24ba728ae3faa";
    hash = "sha256-IcbLKTZhRhvkm1grrrbGR8F6lAAHdj61F/sLStuiE/U=";
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
