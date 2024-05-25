{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  unzip,
  mkgmap,
  mkgmap-splitter,
  osm-extracts,
}:
let
  bounds = fetchurl {
    url = "https://www.thkukuk.de/osm/data/bounds-20240126.zip";
    hash = "sha256-N3QHgWKmbTu6yz9ojKlfwZm46UGeTmtkI2yuB6C7n80=";
  };
  sea = fetchurl {
    url = "https://www.thkukuk.de/osm/data/sea-20240126001517.zip";
    hash = "sha256-YGtlp3K03PDFi3dfWG9bnv3qEWQOmx96eOFm1FU4AJw=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "opentopomap";
  inherit (osm-extracts) version;

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
    (cd data && splitter --precomp-sea=../sea --output=o5m ${osm-extracts.src})
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
    install -Dm644 output/gmapsupp.img $out/otm-russia-nwfd.img
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
