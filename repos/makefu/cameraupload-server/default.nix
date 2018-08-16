{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.python3Packages;buildPythonPackage rec {
  name = "cameraupload-server-${version}";
  version = "0.2.4";

  propagatedBuildInputs = [
    flask
  ];

  src = fetchFromGitHub {
    owner = "makefu";
    repo = "cameraupload-server";
    rev = "c98c8ec";
    sha256 = "0ssgvjm0z399l62wkgjk8c75mvhgn5z7g1dkb78r8vrih9428bb8";
  };

  meta = {
    homepage = https://github.com/makefu/cameraupload-server;
    description = "server side for cameraupload_full";
    license = lib.licenses.asl20;
  };
}
