{ stdenv, python3, myPython3Packages, fetchFromGitHub }:

with python3.pkgs;

buildPythonApplication rec {
  pname = "frida-tools";
  version = "6.0.0";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchFromGitHub {
    owner = "frida";
    repo = "frida-tools";
    rev = version;
    sha256 = "0bq7nbmj4fz728lzc48ar1x42asp3i0h86vin4aqd4widcj4b2yb";
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
