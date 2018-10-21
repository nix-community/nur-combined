{ lib, pkgs, python3Packages, ... }:

with python3Packages; buildPythonPackage rec {
  name = "nodemcu-uploader-${version}";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "ksmit799";
    repo = "switch-launcher";
    rev = version;
    sha256 = "0j24dwiqqjiks59s8gilnplsls130mp1jssg2rpjrvj0jg0w52zz";
  };


  propagatedBuildInputs = [
    pyusb
  ];

  meta = {
    homepage = https://github.com/ksmit799/switch-launcher;
    description = "Desktop switch payload launcher based on a modified reswitched injector";
    license = lib.licenses.bsd3;
  };
}
