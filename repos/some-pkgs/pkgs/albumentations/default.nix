{ lib
, buildPythonPackage
, fetchFromGitHub
, pyyaml
, numpy
, scikitimage
, opencv4
, qudida
, pytestCheckHook
, albumentations
}:

let
  pname = "albumentations";
  version = "1.3.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "albumentations-team";
    repo = pname;
    rev = version;
    hash = "sha256-iqWCSusgZVWpREsDp3Tz+wXZgJX7e9mD/KH+k4sSUH0=";
  };

  postPatch = ''
    sed -i 's/install_requires=get_install.*$/install_requires=INSTALL_REQUIRES + ["opencv"],/' setup.py 
  '';

  propagatedBuildInputs = [
    pyyaml
    numpy
    scikitimage
    opencv4
    qudida
  ];

  checkInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [ "albumentations" ];

  doCheck = false;
  passthru.tests.longCheck = albumentations.overridePythonAttrs (_: { doCheck = true; });

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.mit;
    description = "Image augmentation library for training deep learning models";
    homepage = "https://github.com/albumentations-team/albumentations";
    platforms = lib.platforms.unix;
  };
}
