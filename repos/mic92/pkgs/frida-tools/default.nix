{ stdenv, python3, myPython3Packages, fetchFromGitHub }:

with python3.pkgs;

buildPythonApplication rec {
  pname = "frida-tools";
  version = "1.2.1";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchFromGitHub {
    owner = "frida";
    repo = "frida-tools";
    rev = version;
    sha256 = "1x86w3srmm82h39vb2x53kqla40230z740h93ngrmg7avz0gv3db";
  };

  # attaching does not work in build sandbox
  doCheck = false;

  propagatedBuildInputs = [ pygments prompt_toolkit colorama myPython3Packages.frida ];

  meta = with stdenv.lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = https://www.frida.re/;
    license = licenses.wxWindows;
  };
}
