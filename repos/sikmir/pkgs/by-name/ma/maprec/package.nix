{
  lib,
  stdenv,
  python311Packages,
  fetchFromGitHub,
  thinplatespline,
}:

python311Packages.buildPythonPackage {
  pname = "maprec";
  version = "0-unstable-2023-04-18";
  pyproject = true;

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

  build-system = with python311Packages; [ setuptools ];

  dependencies = with python311Packages; [
    pyyaml
    pyproj
    thinplatespline
  ];

  doCheck = false;

  pythonImportsCheck = [ "maprec" ];

  meta = {
    homepage = "https://github.com/wladich/maprec";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
