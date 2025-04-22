{ lib
, python3
, fetchFromGitHub
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "stream-zip";
  version = "0.0.83";
  pyproject = true;

  src =
  if true then
  fetchurl {
    url = "https://github.com/uktrade/stream-zip/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-LAlABuI/9lWtBr8uiH2Vkc8VYD6h0CwUXMGTwZgOvtI=";
  }
  else
  fetchFromGitHub {
    owner = "uktrade";
    repo = "stream-zip";
    rev = "v${version}";
    hash = "sha256-zcYfpojAy0ZfJHuvYtsEr9SSpTc+tOH8gTKI9Fd4oHg=";
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
