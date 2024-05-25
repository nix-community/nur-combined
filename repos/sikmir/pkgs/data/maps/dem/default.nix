{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  gdal,
  elevation_server,
}:
let
  version = "2014-05-25";

  dem1 = builtins.fromJSON (builtins.readFile ./dem1.json);
  dem3 = builtins.fromJSON (builtins.readFile ./dem3.json);

  meta = {
    description = "Digital Elevation Data";
    homepage = "http://www.viewfinderpanoramas.org/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
in
{
  vrt = stdenvNoCC.mkDerivation rec {
    pname = "dem1-vrt";
    inherit version meta;

    srcs = lib.mapAttrsToList (name: spec: fetchurl spec) dem1;

    unpackPhase = lib.concatMapStringsSep "\n" (src: "unzip ${src}") srcs;

    nativeBuildInputs = [
      unzip
      gdal
    ];

    dontFixup = true;
    preferLocalBuild = true;

    installPhase = ''
      install -Dm644 **/*.hgt -t $out/hgt
      gdalbuildvrt $out/SRTM1.vrt $out/hgt/*.hgt
    '';
  };

  tiles = stdenvNoCC.mkDerivation rec {
    pname = "dem3-tiles";
    inherit version meta;

    # 1 arc-second hgt files are not supported by elevation_server
    srcs = lib.mapAttrsToList (name: spec: fetchurl spec) dem3;

    unpackPhase = lib.concatMapStringsSep "\n" (src: "unzip ${src}") srcs;

    nativeBuildInputs = [
      unzip
      elevation_server
    ];

    dontFixup = true;
    preferLocalBuild = true;

    installPhase = ''
      install -Dm644 **/*.hgt -t $out/hgt
      make_data -hgt $out/hgt -out $out/dem_tiles
    '';
  };
}
