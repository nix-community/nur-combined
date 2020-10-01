{ stdenv
, buildPythonPackage
, isPy3k
, fetchFromGitHub
, mock
, pytest
, pytest-asyncio
}:

buildPythonPackage rec {
  pname = "pygls";
  version = "0.9.1";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "openlawlibrary";
    repo = pname;
    rev = "v${version}";
    sha256 = "1v7x5598d6jg8ya0spqjma56y062rznwimsrp8nq6fkskqgfm0ds";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "pytest==4.5.0" "pytest"
  '';

  checkInputs = [ mock pytest pytest-asyncio ];
  checkPhase = "pytest";

  meta = with stdenv.lib; {
    description = "Pythonic generic implementation of the Language Server Protocol";
    homepage = "https://github.com/openlawlibrary/pygls";
    license = licenses.asl20;
    maintainers = with maintainers; [ metadark ];
  };
}
