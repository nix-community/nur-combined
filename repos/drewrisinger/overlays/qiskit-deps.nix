self: super:

rec {
  # TODO: expand to python37, py38, py3
  # TODO: guard against regression. Condition: if oldAttrs.version < version || (if does not exist py-super.name)

  # overlay the most-updated version of these python packages over the default package set.
  # Needed to allow building on e.g. nixpkgs-19.09
  python3 = super.python3.override {
    packageOverrides = py-self: py-super: {
      arrow = py-super.callPackage ../pkgs/python-modules/arrow { };
      # arrow.overridePythonAttrs (oldAttrs: rec {
      #   version = "0.15.5";
      #   src = py-super.fetchPypi {
      #     inherit (oldAttrs) pname;
      #     inherit version;
      #     sha256 = "0yq2bld2bjxddmg9zg4ll80pb32rkki7xyhgnrqnkxy5w9jf942k";
      #   };
      # });
      # dill = py-super.dill.overridePythonAttrs (oldAttrs: {
      #   version = "0.3.1.1";
      #   sha256 = "42d8ef819367516592a825746a18073ced42ca169ab1f5f4044134703e7a049c";
      # });
      dill = py-super.callPackage ../pkgs/python-modules/dill { };
      marshmallow = py-super.callPackage ../pkgs/python-modules/marshmallow { };
      # marshmallow = py-super.marshmallow.overridePythonAttrs (oldAttrs: {
      #   version = "3.3.0";
      #   src = py-super.fetchPypi {
      #     inherit (oldAttrs) pname;
      #     inherit version;
      #     sha256 = "0yq2bld2bjxddmg9zg4ll80pb32rkki7xyhgnrqnkxy5w9jf942k";
      #   };
      # });
      pybind11 = py-super.callPackage ../pkgs/python-modules/pybind11 { };
      # pybind11 = py-super.pybind11.overridePythonAttrs (oldAttrs: {
      #   version = "2.4.3";
      #   sha256 = "0k89w4bsfbpzw963ykg1cyszi3h3nk393qd31m6y46pcfxkqh4rd";
      # });
    };
  };

  python3Packages = python3.pkgs;
}