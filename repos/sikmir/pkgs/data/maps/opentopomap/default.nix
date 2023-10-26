{ lib, stdenv, fetchFromGitHub, fetchurl, unzip, mkgmap, mkgmap-splitter, osm-extracts }:
let
  bounds = fetchurl {
    url = "https://www.thkukuk.de/osm/data/bounds-20231020.zip";
    hash = "sha256-fQyaYnmP5Qu1iV4R65LMfk8QlTQkKOoIOzxhPWAMD44=";
  };
  sea = fetchurl {
    url = "https://osm.thkukuk.de/osm/data/sea-20231021001503.zip";
    hash = "sha256-3xVcwNbA5bxNM82cLz48UhlcgFE7V2LC/VB0dFAvfu0=";
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

  nativeBuildInputs = [ mkgmap mkgmap-splitter unzip ];

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

  meta = with lib; {
    description = "OpenTopoMap Garmin Edition";
    homepage = "https://garmin.opentopomap.org/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
})
