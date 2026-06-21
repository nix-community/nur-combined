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
  version = "0.1.3-unstable-2026-02-03";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "luigoalma";
    repo = pname;
    rev = "6171591ace81e3029faa32132fd2a5da09d11597";
    sha256 = "sha256-TFRrRI+VZcF86XOhAglkB6tN/Lh/rrQG1lvUm4Uk8/w=";
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
