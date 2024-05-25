{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  thinplatespline,
}:

python3Packages.buildPythonPackage rec {
  pname = "maprec";
  version = "0-unstable-2023-04-18";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "maprec";
    rev = "ccefe661659a30c1bd334710e5884256b945a042";
    hash = "sha256-jm7B5I5OxG3oVxq/AUzN2P1GPa5uQIx0TWMKgx47C28=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail " @ git+https://github.com/wladich/thinplatespline.git" ""
  '';

  propagatedBuildInputs = with python3Packages; [
    pyyaml
    pyproj
    thinplatespline
  ];

  doCheck = false;

  pythonImportsCheck = [ "maprec" ];

  meta = {
    inherit (src.meta) homepage;
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
