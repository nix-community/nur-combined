{ stdenv, python3, myPython3Packages, fetchFromGitHub }:

with python3.pkgs;

buildPythonApplication rec {
  pname = "frida-tools";
  version = "7.2.0";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchFromGitHub {
    owner = "frida";
    repo = "frida-tools";
    rev = version;
    sha256 = "0ypdnk2mk2rf4whbjcibwyksy1hn8nhyj9ax1b9rag9lxz2l7nqa";
  };

  # attaching does not work in build sandbox
  doCheck = false;

  propagatedBuildInputs = [
    pygments prompt_toolkit colorama myPython3Packages.frida
  ];

  meta = with stdenv.lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://www.frida.re/";
    license = licenses.wxWindows;
  };
}
