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
      # Needed for nixpkgs-20.03
      sparse = overrideSuperVersionIfNewer py-super.sparse (py-self.callPackage ../pkgs/python-modules/sparse { });
      # Needed for nixpkgs < nixos-unstable
      websocket_client = overrideSuperVersionIfNewer py-super.websocket_client (py-self.callPackage ../pkgs/python-modules/websocket-client { });
      # needed for nixpkgs < nixos-21.05, broken
      symengine = overrideSuperVersionIfNewer py-super.symengine (py-self.callPackage ../pkgs/python-modules/symengine { inherit (self) symengine; });
    };
  };

  symengine = self.callPackage ../pkgs/libraries/symengine { }; # update symengine to match python version that's unbroken/pinned above

  python3Packages = python3.pkgs;
}
