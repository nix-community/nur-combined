self: super: let
  arc = import ../canon.nix { inherit self super; };
in {
  inherit (arc.lib.overlayOverride {
    inherit self super;
    attr = "mkShell";
    withAttr = "mkShell'";
    superAttr = "nixpkgsMkShell";
    fallback = { ... }: arc.build.mkShell';
  }) mkShell mkShell' nixpkgsMkShell;

  shells = arc.super.lib.makeOrExtend super "shells" arc.shells;

  callPackageOverrides = super.callPackageOverrides or { } // {
    mkShellEnv = {
      mkShell = self.nixpkgsMkShell or super.mkShell or (throw "mkShell missing");
    };
    mkShell' = {
      mkShell = self.nixpkgsMkShell or super.mkShell or (throw "mkShell missing");
    };
  };
}
