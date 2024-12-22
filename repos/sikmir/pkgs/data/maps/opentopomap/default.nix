{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  unzip,
  mkgmap,
  mkgmap-splitter,
}:
let
  version = "241221";
  bounds = fetchurl {
    url = "https://www.thkukuk.de/osm/data/bounds-20241220.zip";
    hash = "sha256-ys79/azaEDAcUNiULM3xBDyQAkanWM72cOIVBaa9Zyw=";
  };
  sea = fetchurl {
    url = "https://www.thkukuk.de/osm/data/sea-20241221001512.zip";
    hash = "sha256-6CCHwd71iK0F+J5qxE4PHSxq0pv/VHL7gwBb4ZPFmoU=";
  };
  armenia = fetchurl {
    url = "https://download.geofabrik.de/asia/armenia-${version}.osm.pbf";
    hash = "sha256-t1CSs5+VnZfVA6U98OESTq+ZeTPy/NhF7ldH+mDX04s=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "otm-armenia";
  inherit version;

  src = fetchFromGitHub {
    owner = "der-stefan";
    repo = "OpenTopoMap";
    rev = "e4467cfc2064afc379b0f8e8360db1740099cca3";
    hash = "sha256-3fymFZHFnivdgIWaJiRK6bvIRIay4+AnN1ns67lvq5I=";
  };

  sourceRoot = "${finalAttrs.src.name}/garmin";

  nativeBuildInputs = [
    mkgmap
    mkgmap-splitter
    unzip
  ];

  postPatch = ''
    unzip ${bounds} -d bounds
    unzip ${sea}
    mkdir data
  '';

  buildPhase = ''
    (cd data && splitter --precomp-sea=../sea --output=o5m ${armenia})
    (cd style/typ && mkgmap --family-id=35 opentopomap.txt)

    mkgmap \
      -c opentopomap_options \
      --style-file=style/opentopomap \
      --precomp-sea=sea \
      --output-dir=output \
      --bounds=bounds \
      data/6324*.o5m \
      style/typ/opentopomap.typ
  '';

  installPhase = ''
    install -Dm644 output/gmapsupp.img $out/otm-armenia.img
  '';

  meta = {
    description = "OpenTopoMap Garmin Edition";
    homepage = "https://garmin.opentopomap.org/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
})
