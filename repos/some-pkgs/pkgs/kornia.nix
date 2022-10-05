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
, packaging
  # For tests
, kornia
}:
buildPythonPackage rec {
  pname = "kornia";
  version = "0.6.7";

  src = fetchFromGitHub {
    owner = "kornia";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-SWSVGwc6jet5p8Pm3Cz1DR70bhnZDMIwJzFAliOgjoA=";
  };
  postPatch = ''
    substituteInPlace setup.py --replace "'pytest-runner'" ""
  '';

  buildInputs = [ packaging ];
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
