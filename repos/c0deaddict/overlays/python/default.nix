let

  myPythonOverride = {
    packageOverrides = import ./overrides.nix;
  };

in

self: super: rec {

  # https://discourse.nixos.org/t/how-to-add-custom-python-package/536/4
  python = super.python.override myPythonOverride;
  python2 = super.python2.override myPythonOverride;
  python3 = super.python3.override myPythonOverride;
  python36 = super.python36.override myPythonOverride;
  python37 = super.python37.override myPythonOverride;
  python38 = super.python38.override myPythonOverride;

  pythonPackages = python.pkgs;
  python2Packages = python.pkgs;
  python3Packages = python3.pkgs;
  python36Packages = python36.pkgs;
  python37Packages = python37.pkgs;
  python38Packages = python38.pkgs;

}
