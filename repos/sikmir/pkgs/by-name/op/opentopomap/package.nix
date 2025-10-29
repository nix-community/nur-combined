{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchwebarchive,
  fetchurl,
  unzip,
  mkgmap,
  mkgmap-splitter,
}:
let
  version = "251028";
  bounds = fetchwebarchive {
    url = "https://www.thkukuk.de/osm/data/bounds-20250110.zip";
    timestamp = "20250116113456";
    hash = "sha256-KRsCgzFUoEi7Ou6gUsQp/4l7V9jW/q3Zy3HikW9SCOs=";
  };
  sea = fetchwebarchive {
    url = "https://www.thkukuk.de/osm/data/sea-20250114001521.zip";
    timestamp = "20250116115241";
    hash = "sha256-1why/zj+/S4F1CbRdhzMen75WA2O5guMKjj3Gk4RrFw=";
  };
  armenia = fetchurl {
    url = "https://download.geofabrik.de/asia/armenia-${version}.osm.pbf";
    hash = "sha256-5RVamKKGidYtH19RjHV7qKk4GmYxHnL1jKAU3Zd3RF0=";
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
