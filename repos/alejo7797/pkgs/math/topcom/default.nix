{
  stdenv,
  lib,
  fetchurl,
  gmp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "topcom";
  version = "1.1.2";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchurl {
    url = "https://www.wm.uni-bayreuth.de/de/team/rambau_joerg/TOPCOM-Downloads/TOPCOM-${
      builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }.tgz";
    hash = "sha256-T7EHVO5bdgVkQf6pjyyN7l228phNjBQoO0kjmtQ3irY=";
  };

  enableParallelBuilding = true;

  buildInputs = [
    gmp
  ];

  meta = {
    description = "Compute Triangulations Of Point Configurations and Oriented Matroids";
    license = lib.licenses.gpl3Plus;
    homepage = "https://www.wm.uni-bayreuth.de/de/team/rambau_joerg/TOPCOM/";
  };
})
