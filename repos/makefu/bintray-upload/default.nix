{ pkgs, ... }:

pkgs.python3Packages.buildPythonPackage rec {
  name = "bintray-upload-${version}";
  version = "0.1.2";
  src = pkgs.fetchFromGitHub {
    owner = "makefu";
    repo = "bintray-upload";
    rev = "4e76724";
    sha256 = "1401saisk98n5wgw73nwh8hb484vayw5c6dlypxc1fp4ybym4zi9";
  };

  propagatedBuildInputs = with pkgs.python3Packages; [ requests ];

  meta = {
    description = "Simple BinTray utility for uploading packages";
    license = pkgs.stdenv.lib.licenses.asl20;
  };
}
