{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.python3Packages;
let
  ftputil = buildPythonPackage rec {
    version = "3.3.1";
    name = "ftputil-${version}";
    doCheck = false;
    src = pkgs.fetchurl {
      url = "mirror://pypi/f/ftputil/${name}.tar.gz";
      sha256 = "bc88f35cc7f5f292ec4b56e99c8b05d361de1cc8b330050e32b0c4ecaa2d2b01";
    };
};
in buildPythonPackage rec {
  name = "elchhub-${version}";
  version = "1.0.5";
  propagatedBuildInputs = [
    flask
    requests
    ftputil
    redis
  ];
  doCheck = false;
  src = fetchFromGitHub {
    owner = "krebs";
    repo = "elchhub";
    rev = "58707c6";
    sha256 = "04spbcr660dxyc4jvrai094na25zizd2cfi36jz19lahb0k66lqm";
  };
  meta = {
    homepage = https://github.com/krebs/elchhub;
    description = "elchhub";
    license = lib.licenses.wtfpl;
  };
}
