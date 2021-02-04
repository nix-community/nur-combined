{ lib, stdenvNoCC, fetchurl, unzip
, withVRT ? true, gdal }:
let
  dem1 = builtins.fromJSON (builtins.readFile ./dem1.json);
in
stdenvNoCC.mkDerivation {
  pname = "dem";
  version = "2014-05-25";

  srcs = lib.mapAttrsToList (name: spec: fetchurl spec) dem1;

  unpackPhase = "for src in $srcs; do ${unzip}/bin/unzip $src; done";

  nativeBuildInputs = lib.optional withVRT gdal;

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  preferLocalBuild = true;

  installPhase = ''
    install -Dm644 **/*.hgt -t $out
  '' + lib.optionalString withVRT ''
    gdalbuildvrt $out/SRTM.vrt $out/*.hgt
  '';

  meta = with lib; {
    description = "Digital Elevation Data";
    homepage = "http://www.viewfinderpanoramas.org/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
