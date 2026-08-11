{ lib
, python3
, fetchFromGitHub
, openssl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "aia";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "danilobellini";
    repo = "aia";
    rev = "v${version}";
    hash = "sha256-FKnDn7NsCEOV7aTpwtvCHuQtPXibPgI+r9+rXC+EDKM=";
  };

  postPatch = ''
    substituteInPlace aia.py \
      --replace-fail '"openssl"' '"${openssl}/bin/openssl"'
  '';

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "aia" ];

  meta = with lib; {
    description = "Certificate Authority Information Access in Python";
    homepage = "https://github.com/danilobellini/aia";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
