{ stdenv, python3, myPython3Packages, fetchFromGitHub }:

with python3.pkgs;

buildPythonApplication rec {
  pname = "frida-tools";
  version = "8.2.0";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchPypi {
    inherit pname version;
    sha256 = "e336e29ec6d82bf8d3994dfe4000ad88c0f10f00221dc85b8fea7724aa93b1b0";
  };

  propagatedBuildInputs = [
    pygments
    prompt_toolkit
    colorama
    myPython3Packages.frida
  ];

  meta = with stdenv.lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://www.frida.re/";
    license = licenses.wxWindows;
  };
}
