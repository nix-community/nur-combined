self: super:

rec {
  # TODO: expand to python37, py38, py3
  # TODO: guard against regression. Condition: if oldAttrs.version < version || (if does not exist py-super.name)

  # overlay the most-updated version of these python packages over the default package set.
  # Needed to allow building on e.g. nixpkgs-19.09
  python3 = super.python3.override {
    packageOverrides = py-self: py-super: {
      arrow = py-super.callPackage ../pkgs/python-modules/arrow { };
      dill = py-super.callPackage ../pkgs/python-modules/dill { };
      marshmallow = py-super.callPackage ../pkgs/python-modules/marshmallow { };
      pybind11 = py-super.callPackage ../pkgs/python-modules/pybind11 { };
      scipy = py-super.callPackage ../pkgs/python-modules/scipy { };
    };
  };

  python3Packages = python3.pkgs;
}