{ lib
, buildPythonPackage
, fetchFromGitHub
, pytorch
, pytestCheckHook
  # for tests
, accelerate
}:
buildPythonPackage rec {
  name = "accelerate";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = name;
    rev = "v${version}";
    hash = "sha256-Fuq13JWUXCG4NEeR5rWn41JDmTI6tyImCrOxss6ekNs=";
  };

  propagatedBuildInputs = [ pytorch ];

  checkInputs = [ pytestCheckHook ];

  doCheck = false;
  passthru.tests.accelerateTests = accelerate.overridePythonAttrs (a: {
    doCheck = true;
  });

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.asl20;
    description = "A library by huggingface that provides a simple way to train and use PyTorch models with multi-GPU, TPU, mixed-precision";
    homepage = "https://github.com/huggingface/accelerate";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}

