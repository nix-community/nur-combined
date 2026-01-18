{
  lib,
  fetchpatch,
  fetchFromGitHub,
  callPackage,
  buildPythonApplication,
  pycurl,
  defusedxml,
  setuptools,
}:

let
  cryptography = callPackage ./python-cryptography-43.0.3/package.nix { };
in
buildPythonApplication rec {
  pname = "cleaninty";
  version = "0.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "luigoalma";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-QVttOy3WPFZXvbNaJUhFSsEWwPDZgkGuDBR7zxlS+w8=";
  };

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    cryptography
    pycurl
    defusedxml
  ];

  meta = with lib; {
    description = "Perform some Nintendo console client to server operations";
    homepage = "https://github.com/luigoalma/cleaninty";
    license = licenses.unlicense;
    platforms = platforms.all;
    mainProgram = "cleaninty";
  };
}
