{
  lib,
  fetchFromGitHub,
  python3Packages,
  bounded-pool-executor,
}:

python3Packages.buildPythonPackage rec {
  pname = "pqdm";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "niedakh";
    repo = "pqdm";
    rev = "v${version}";
    hash = "sha256-qB/0TOxD7XCLsr3bKDIKZvYa8g2N95SzTeDiRgJp3Jk=";
  };

  dependencies = with python3Packages; [
    bounded-pool-executor
    tqdm
    typing-extensions
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "pqdm" ];

  meta = {
    description = "Comfortable parallel TQDM using concurrent.futures";
    homepage = "https://github.com/niedakh/pqdm";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
