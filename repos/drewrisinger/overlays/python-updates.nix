self: super:

rec {
  # TODO: expand to python37, py38, py3

  # overlay the most-updated version of these python packages over the default package set.
  # Needed to allow building on e.g. nixpkgs-19.09
  python3 = super.python3.override {
    packageOverrides = py-self: py-super:
    let
      # Check if the py-super version is newer and use that if so.
      overrideSuperVersionIfNewer = superPyPackage: localPyPackage:
        if super.lib.versionAtLeast superPyPackage.version localPyPackage.version then
          superPyPackage
        else
          localPyPackage;
    in
    {
      # Needed for nixpkgs < 21.05, older version incompatible with pyquil/rigetti
      lark-parser = overrideSuperVersionIfNewer py-super.lark-parser (py-self.callPackage ../pkgs/python-modules/lark-parser { });
      pydantic = overrideSuperVersionIfNewer py-super.pydantic (py-self.callPackage ../pkgs/python-modules/pydantic { });
      # Needed for nixpkgs < nixos-unstable
      docplex = overrideSuperVersionIfNewer py-super.docplex (py-self.callPackage ../pkgs/python-modules/docplex { });
      websocket_client = overrideSuperVersionIfNewer py-super.websocket_client (py-self.callPackage ../pkgs/python-modules/websocket-client { });
      yfinance = overrideSuperVersionIfNewer py-super.yfinance (py-self.callPackage ../pkgs/python-modules/yfinance { });
      # needed for nixpkgs < nixos-21.05, broken
      symengine = overrideSuperVersionIfNewer py-super.symengine (py-self.callPackage ../pkgs/python-modules/symengine { inherit (self) symengine; });
    };
  };

  symengine = self.callPackage ../pkgs/libraries/symengine { }; # update symengine to match python version that's unbroken/pinned above

  python3Packages = python3.pkgs;
}
