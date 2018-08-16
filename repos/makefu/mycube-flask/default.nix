{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.pythonPackages;buildPythonPackage rec {
  name = "mycube-flask-${version}";
  version = "0.2.3.4";
  propagatedBuildInputs = [
    flask
    redis
  ];
  src = fetchFromGitHub {
    owner = "makefu";
    repo = "mycube-flask";
    rev = "48dc6857";
    sha256 = "1ax1vz6m5982l1mmp9vmywn9nw9p9h4m3ss74zazyspxq1wjim0v";
  };
  meta = {
    homepage = https://github.com/makefu/mycube-flask;
    description = "flask app for mycube";
    license = lib.licenses.asl20;
  };
}
