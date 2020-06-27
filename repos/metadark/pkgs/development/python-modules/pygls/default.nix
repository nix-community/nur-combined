{ stdenv, buildPythonPackage, isPy3k, fetchFromGitHub
, mock, pytest, pytest-asyncio
}:

buildPythonPackage rec {
  pname = "pygls";
  version = "0.8.1";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "openlawlibrary";
    repo = pname;
    rev = "v${version}";
    sha256 = "1853rfdks5n8nw6ig96j7his5kqd75hrvzvd0win4niycaqsag6m";
  };

  # Check depends on pytest 4.5.0
  # checkInputs = [ mock pytest pytest-asyncio ];
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Pythonic generic implementation of the Language Server Protocol";
    homepage = "https://github.com/openlawlibrary/pygls";
    license = licenses.asl20;
    maintainers = with maintainers; [ metadark ];
  };
}
