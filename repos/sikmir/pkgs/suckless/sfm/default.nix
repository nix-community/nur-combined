{ lib, stdenv, fetchFromGitHub, conf ? null }:

stdenv.mkDerivation rec {
  pname = "sfm";
  version = "2021-05-17";

  src = fetchFromGitHub {
    owner = "afify";
    repo = pname;
    rev = "e66240c2769b4a3980808e80e0505e6696a4fc06";
    hash = "sha256-FmKdir+KL0rtKTXGI9EF5njfcBVtNC/Es+OluSmlW6w=";
  };

  patches = [ ./config.patch ];

  configFile = lib.optionalString (conf!=null) (lib.writeText "config.def.h" conf);

  postPatch = lib.optionalString (conf!=null) "cp ${configFile} config.def.h";

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Simple file manager";
    inherit (src.meta) homepage;
    license = licenses.isc;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
