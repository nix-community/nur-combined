{
  lib,
  stdenv,
  fetchzip,
}:
let
  version = "0.8.220";
  filename = "lgmt${lib.replaceStrings [ "." ] [ "" ] version}.zip";
in
stdenv.mkDerivation {
  pname = "gmaptool";
  inherit version;

  src = fetchzip {
    url = "https://www.gmaptool.eu/sites/default/files/${filename}";
    hash = "sha256-/hEkStsx6k6HU+WdqamP2FFFykEtIOrqh8JRLYr2yXE=";
    stripRoot = false;
  };

  dontFixup = true;

  installPhase = "install -Dm755 gmt -t $out/bin";

  meta = {
    description = "Program for splitting and merging maps in Garmin format";
    homepage = "https://www.gmaptool.eu";
    license = lib.licenses.cc-by-sa-30;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
    mainProgram = "gmt";
    skip.ci = true;
  };
}
