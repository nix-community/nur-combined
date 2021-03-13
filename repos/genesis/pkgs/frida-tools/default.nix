{ lib, python3, myPython3Packages, fetchFromGitHub }:

with python3.pkgs;

buildPythonApplication rec {
  pname = "frida-tools";
  version = "9.0.1";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchPypi {
    inherit pname version;
    sha256 = "1373ab31533d2ad3a5a4ab3b801c96db23f4fa147a2fb49eb4bd29e2086766e5";
  };

  propagatedBuildInputs = [
    pygments
    prompt_toolkit
    colorama
    myPython3Packages.frida
  ];

  meta = with lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://www.frida.re/";
    license = licenses.wxWindows;
  };
}
