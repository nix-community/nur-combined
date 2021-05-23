{ lib, stdenv, fetchFromGitHub, conf ? null }:

stdenv.mkDerivation rec {
  pname = "sfm";
  version = "2021-05-22";

  src = fetchFromGitHub {
    owner = "afify";
    repo = pname;
    rev = "7b0060575657e47ca9edadfd4ebc01e73f8fb72e";
    hash = "sha256-B8RZ9GnjR1ZxVk6ut7KBEYPUXiewpYgqzUUN0G1bx+o=";
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
