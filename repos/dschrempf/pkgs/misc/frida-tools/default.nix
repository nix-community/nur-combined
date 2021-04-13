# This is largely taken from the NUR package of genesis, see
# https://github.com/nix-community/nur-combined/blob/master/repos/genesis/pkgs/frida-tools/default.nix.
{ lib, python3, frida, fetchFromGitHub }:

python3.pkgs.buildPythonApplication rec {
  pname = "frida-tools";
  version = "9.2.3";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "10p24ip5jzg04n35baw4mkxwand5hfwf0x0dii15zrf4q93x1f96";
  };

  propagatedBuildInputs = with python3.pkgs; [
    pygments
    prompt_toolkit
    colorama
    frida
  ];

  meta = with lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://www.frida.re/";
    maintainers = let dschrempf = import ../../dschrempf.nix; in [ dschrempf ];
    license = licenses.wxWindows;
  };
}
