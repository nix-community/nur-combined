{ lib
, buildPythonPackage
, fetchFromGitHub
, pytorch
, setuptools
, pytest
, pytestCheckHook
, accelerate
, furo
, opencv4
, matplotlib
, pyyaml
, scipy
, torchvision
  # For tests
, kornia
}:
buildPythonPackage rec {
  name = "kornia";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "kornia";
    repo = name;
    rev = "v${version}";
    hash = "sha256-L1ouqjSEVtvHYYinQr2GWLGb4RsVVT2Y1D2SVq+dsYE=";
  };
  postPatch = ''
    substituteInPlace setup.py --replace "'pytest-runner'" ""
  '';

  propagatedBuildInputs = [ pytorch ];
  checkInputs = [ pytestCheckHook scipy ];

  passthru.extras-require.x = [
    accelerate
    torchvision
    opencv4
    pyyaml
    matplotlib
  ];

  disabledTestPaths = [ "test/test_contrib.py" ];

  doCheck = false;
  passthru.tests.korniaTests = kornia.overridePythonAttrs (a: {
    doCheck = true;
  });

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.asl20;
    description = "Open Source Differentiable Computer Vision Library";
    homepage = "https://kornia.github.io/";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
