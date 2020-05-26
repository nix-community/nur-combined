{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "gmaptool";
  version = "0.8.220";

  src = fetchzip {
    url = "https://www.gmaptool.eu/sites/default/files/lgmt${stdenv.lib.replaceStrings [ "." ] [ "" ] version}.zip";
    sha256 = "0wf9ys52slf2hzmfl81d8754alfqiylsk7g5af3lxsiivd5284gy";
    stripRoot = false;
  };

  dontBuild = true;
  dontFixup = true;

  installPhase = "install -Dm755 gmt -t $out/bin";

  meta = with stdenv.lib; {
    description = "Program for splitting and merging maps in Garmin format";
    homepage = "https://www.gmaptool.eu";
    license = licenses.cc-by-sa-30;
    maintainers = with maintainers; [ sikmir ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
