let

  overridePython = oldPython:
    let
      python = oldPython.override {
        packageOverrides = import ./overrides.nix;
        self = python;
      };
    in python;

in self: super: rec {

  # https://discourse.nixos.org/t/how-to-add-custom-python-package/536/4
  python = overridePython super.python;
  python2 = overridePython super.python2;
  python3 = overridePython super.python3;
  python36 = overridePython super.python36;
  python37 = overridePython super.python37;
  python38 = overridePython super.python38;
  python39 = overridePython super.python39;

  pythonPackages = python.pkgs;
  python2Packages = python.pkgs;
  python3Packages = python3.pkgs;
  python36Packages = python36.pkgs;
  python37Packages = python37.pkgs;
  python38Packages = python38.pkgs;
  python39Packages = python39.pkgs;

}
