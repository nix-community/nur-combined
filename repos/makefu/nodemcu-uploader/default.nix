{ lib, pkgs, pythonPackages, ... }:

with pythonPackages; buildPythonPackage rec {
  name = "nodemcu-uploader-${version}";
  version = "0.4.1";
  propagatedBuildInputs = [
    pyserial
    wrapt
  ];

  src = pkgs.fetchFromGitHub {
    owner = "kmpm";
    repo = "nodemcu-uploader";
    rev = "v${version}";
    sha256 = "055pvlg544vb97kaqnnq51fs9f9g75vwgbazc293f3g1sk263gmn";
  };

  doCheck = false;

  meta = {
    homepage = https://github.com/kmpm/nodemcu-uploader;
    description = "tool for uploading files to NodeMCU filesystem";
    license = lib.licenses.mit;
  };
}
