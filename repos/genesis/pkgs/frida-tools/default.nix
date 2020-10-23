{ stdenv, python3, myPython3Packages, fetchFromGitHub }:

with python3.pkgs;

buildPythonApplication rec {
  pname = "frida-tools";
  version = "9.0.0";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchPypi {
    inherit pname version;
    sha256 = "164bbpdif94f69aag1d21cm3ymabyv7dl9fnvbhp0pihg1807f9k";
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
