{ lib, stdenv, fetchzip }:
let
  version = "0.8.220";
  filename = "lgmt${lib.replaceStrings [ "." ] [ "" ] version}.zip";
in
stdenv.mkDerivation {
  pname = "gmaptool";
  inherit version;

  src = fetchzip {
    url = "https://www.gmaptool.eu/sites/default/files/${filename}";
    sha256 = "0wf9ys52slf2hzmfl81d8754alfqiylsk7g5af3lxsiivd5284gy";
    stripRoot = false;
  };

  dontFixup = true;

  installPhase = "install -Dm755 gmt -t $out/bin";

  meta = with lib; {
    description = "Program for splitting and merging maps in Garmin format";
    homepage = "https://www.gmaptool.eu";
    license = licenses.cc-by-sa-30;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "i686-linux" "x86_64-linux" ];
    skip.ci = true;
  };
}
