{
  lib,
  python3Packages,
  fetchFromGitHub,
  fetchurl,
  writableTmpDirAsHomeHook,
}:
let
  testdata = import ./testdata.nix { inherit fetchurl; };
in
python3Packages.buildPythonApplication rec {
  pname = "gpxelevations";
  version = "0.3.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tkrajina";
    repo = "srtm.py";
    tag = "v${version}";
    hash = "sha256-/AGvFE74sJTnn70VklQp0MG+7dsooavAdSTyV2oJM+I=";
  };

  postPatch = ''
    # https://docs.python.org/3/whatsnew/3.12.html#id3
    substituteInPlace test.py \
      --replace-fail assertNotEquals assertNotEqual
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    requests
    gpxpy
  ];

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  dontUseSetuptoolsCheck = true;

  checkPhase = ''
    mkdir -p $HOME/.cache/srtm
    ${lib.concatMapStringsSep "\n" (hgt: ''
      cp ${hgt} $HOME/.cache/srtm/${hgt.name}
    '') testdata}

    ${python3Packages.python.interpreter} -m unittest test
  '';

  meta = {
    description = "Geo elevation data parser for \"The Shuttle Radar Topography Mission\" data";
    homepage = "https://github.com/tkrajina/srtm.py";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
