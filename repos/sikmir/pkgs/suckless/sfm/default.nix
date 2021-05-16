{ lib, stdenv, fetchFromGitHub, conf ? null }:

stdenv.mkDerivation rec {
  pname = "sfm";
  version = "2021-05-16";

  src = fetchFromGitHub {
    owner = "afify";
    repo = pname;
    rev = "cc1efcf914bbfe75cbd2ce2a1a90e764d5b88bfd";
    hash = "sha256-6pdxfRhvZDde332BFIYlcia5JVMS79HlgEZ/T5CniZo=";
  };

  configFile = lib.optionalString (conf!=null) (lib.writeText "config.def.h" conf);

  postPatch = lib.optionalString (conf!=null) "cp ${configFile} config.def.h";

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Simple file manager";
    inherit (src.meta) homepage;
    license = licenses.isc;
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
}
