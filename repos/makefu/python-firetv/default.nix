{ lib, pkgs, python2Packages, ... }:
# requires libusb1 from unstable
with python2Packages; let

 python-adb = buildPythonPackage rec {
    pname = "adb";
    version = "1.2.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0v4my47ikgkbq04gdllpx6kql5cfh7dnpq2fk72x03z74mqri7v8";
    };

    propagatedBuildInputs = [ libusb1 m2crypto ];
    meta = {
      homepage = https://github.com/google/python-adb;
      description = "Python ADB + Fastboot implementation";
      license = lib.licenses.asl20;
    };
  };
in
 buildPythonPackage rec {
  name = "python-firetv-${version}";
  version = "1.0.5";

  src = pkgs.fetchFromGitHub {
    owner = "happyleavesaoc";
    repo = "python-firetv";
    # rev = version;
    rev = "55406c6";
    sha256 = "1r2yighilchs0jvcvbngkjxkk7gp588ikcl64x7afqzxc6zxv7wp";
  };

  propagatedBuildInputs = [ python-adb flask pyyaml ];
  meta = {
    homepage = https://github.com/happyleavesaoc/python-firetv;
    description = "provides state informations and some control of an amazon firetv";
    license = lib.licenses.mit;
  };
}
