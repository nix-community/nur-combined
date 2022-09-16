{ lib, stdenv, fetchFromGitHub, fetchurl, unzip, mkgmap, mkgmap-splitter, osm-extracts }:
let
  bounds = fetchurl {
    url = "http://osm.thkukuk.de/data/bounds-20220909.zip";
    hash = "sha256-79zepbGXulWr2QGlFVcIMkzASlTg5DqOEPvx0jcWLYw=";
  };
  sea = fetchurl {
    url = "http://osm.thkukuk.de/data/sea-20220914001527.zip";
    hash = "sha256-ntafRbfMMnHy2IlhqKE/DaMinsu9NaXA41HhXb6YVf4=";
  };
in
stdenv.mkDerivation rec {
  pname = "opentopomap";
  inherit (osm-extracts) version;

  src = fetchFromGitHub {
    owner = "der-stefan";
    repo = "OpenTopoMap";
    rev = "e4467cfc2064afc379b0f8e8360db1740099cca3";
    hash = "sha256-3fymFZHFnivdgIWaJiRK6bvIRIay4+AnN1ns67lvq5I=";
  };

  sourceRoot = "${src.name}/garmin";

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
}
