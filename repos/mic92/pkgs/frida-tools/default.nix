{ stdenv, python3, myPython3Packages, fetchFromGitHub }:

with python3.pkgs;

buildPythonApplication rec {
  pname = "frida-tools";
  version = "7.2.2";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchFromGitHub {
    owner = "frida";
    repo = "frida-tools";
    rev = version;
    sha256 = "173kcfi1v5p6cisj37abswj2kfkdv0a5ilfb685z1z74h5fd9xa7";
  };

  # attaching does not work in build sandbox
  doCheck = false;

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
