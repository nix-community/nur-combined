/*
the source was removed from github
https://web.archive.org/web/20240918163105/https://github.com/uktrade/stream-zip

reconstructed source with git tags:
https://github.com/milahu/stream-zip

alternatives:
https://github.com/sandes/zipfly # 2025, 500 stars
https://github.com/arjan-s/python-zipstream # 2023, 50 stars
https://github.com/kbbdy/zipstream # 2020, 40 stars
https://github.com/pR0Ps/zipstream-ng # 30 stars
https://github.com/DoctorJohn/aiohttp-zip-response # 1 stars
https://github.com/baldhumanity/py_stream_zip # 0 stars

see also
https://github.com/milahu/stream-zip/issues/1
alternatives to stream-zip
*/

{ lib
, python3
, fetchFromGitHub
, fetchPypi
, fetchurl
}:

python3.pkgs.buildPythonPackage rec {
  pname = "stream-zip";
  version = "0.0.81";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "stream-zip";
    rev = "v${version}";
    hash = "sha256-kSRCl0mVgntC53cCB6u5OAkzFk+a9yoyfiUJH8yLqAI=";
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
    homepage = "https://pypi.org/project/stream-zip/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
