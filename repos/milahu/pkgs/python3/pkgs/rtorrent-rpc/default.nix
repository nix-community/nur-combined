{ lib
, buildPythonPackage
, fetchFromGitHub
, flit-core
, bencode2
, certifi
, typing-extensions
, urllib3
, coverage
, mypy
, orjson
, pre-commit
, pytest
, sphinx-autobuild
, furo
, sphinx
}:

buildPythonPackage rec {
  pname = "rtorrent-rpc";
  version = "0.7.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "trim21";
    repo = "rtorrent-rpc";
    rev = "v${version}";
    hash = "sha256-YC/qrSBiBzoA7CBHoTyJOf5Ipgg/nZPHCt0VHcHWk9o=";
  };

  nativeBuildInputs = [
    flit-core
  ];

  propagatedBuildInputs = [
    bencode2
    certifi
    typing-extensions
    urllib3
  ];

  passthru.optional-dependencies = {
    dev = [
      coverage
      mypy
      orjson
      pre-commit
      pytest
      sphinx-autobuild
    ];
    docs = [
      furo
      sphinx
    ];
    orjson = [
      orjson
    ];
  };

  pythonImportsCheck = [ "rtorrent_rpc" ];

  meta = with lib; {
    description = "A typed rtorrent rpc client";
    homepage = "https://github.com/trim21/rtorrent-rpc";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
