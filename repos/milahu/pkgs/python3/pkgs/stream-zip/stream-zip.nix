{ lib
, python3
, fetchFromGitHub
, fetchPypi
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "stream-zip";
  version = "0.0.84";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "uktrade";
    repo = "stream-zip";
    rev = "v${version}";
    hash = "sha256-XezEeG214Ng5D/MEhxl475PWt96Zk7x0jeIwDgRRFiE=";
  };

  nativeBuildInputs = [
    python3.pkgs.hatchling
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pycryptodome
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    ci = [
      coverage
      pycryptodome
      pytest
      pytest-cov
      pyzipper
      stream-unzip
    ];
    dev = [
      coverage
      pytest
      pytest-cov
      pyzipper
      stream-unzip
    ];
  };

  pythonImportsCheck = [ "stream_zip" ];

  meta = with lib; {
    description = "Python function to construct a ZIP archive on the fly";
    homepage = "https://github.com/uktrade/stream-zip";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
