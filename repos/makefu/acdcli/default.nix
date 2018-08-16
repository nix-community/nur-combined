{ lib, pkgs, python3Packages, fetchurl, ... }:

with python3Packages; buildPythonPackage rec {
  name = "acdcli-${version}";
  version = "0.3.2";
  propagatedBuildInputs = [
    dateutil colorama fusepy appdirs requests requests_toolbelt six
  ];
  src = fetchurl {
    url = "mirror://pypi/a/acdcli/${name}.tar.gz";
    sha256 = "1ak9xxpyb7n6iyalf2082jpimklakm0fgm7vsv7qcm8wy6vlq2cw";
  };
  doCheck = false; # ImportError: Failed to import test module: tests

  # acd_cli gets dumped in bin and gets overwritten by fixupPhase
  postFixup = ''
    mv $out/bin/.acd_cli.py-wrapped $out/bin/acd_cli.py
  '';
  meta = {
    description = "communicate with amazon drive";
  };
}
