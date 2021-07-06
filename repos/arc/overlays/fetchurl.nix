self: super: let
  arc = import ../canon.nix { inherit self super; };
in assert ! super ? nixpkgsFetchurl; {
  inherit (arc.lib.overlayOverride {
    inherit self super;
    attr = "fetchurl";
    withAttr = "nixFetchurl";
    superAttr = "nixpkgsFetchurl";
    fallback = { ... }: arc.build.nixFetchurl;
  }) fetchurl nixFetchurl nixpkgsFetchurl;

  callPackageOverrides = super.callPackageOverrides or { } // {
    nixFetchurl = {
      fetchurl = self.nixpkgsFetchurl or super.fetchurl or (throw "TODO");
    };
  };
}
