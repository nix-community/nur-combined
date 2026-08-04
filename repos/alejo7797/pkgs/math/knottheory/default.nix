{
  lib,
  fetchurl,
  unzip,
  stdenv,
  mathematica,
}:

stdenv.mkDerivation {
  pname = "knottheory";
  version = "2024-10-29";

  src = fetchurl {
    url = "https://drorbn.net/AcademicPensieve/Projects/KnotTheory/KnotTheory.zip";
    hash = "sha256-JNi/6RdNDcqEoNIgqPqfZU1+TxLKFboftwfOc72noQI=";
  };

  nativeBuildInputs = [ unzip ];

  patches = [ ./KnotTheory.patch ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/WolframEngine/Applications/KnotTheory"
    cp -r ./* "$out/share/WolframEngine/Applications/KnotTheory"

    mkdir -p "$out/share/Wolfram/Applications"
    ln -s ../../WolframEngine/Applications/KnotTheory \
      "$out/share/Wolfram/Applications/KnotTheory"

    runHook postInstall
  '';

  meta = {
    description = "Dror Bar-Natan's Mathematica package for studying knot theory";
    license = lib.licenses.unfree;
    homepage = "http://katlas.org/wiki/KnotTheory";
    inherit (mathematica.meta) platforms;
  };
}
