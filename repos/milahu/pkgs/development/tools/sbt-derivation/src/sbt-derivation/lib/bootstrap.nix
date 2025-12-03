pkgs:
pkgs.lib.fix (self: {
  __functor = self': args: let
    callPackage = pkgs.lib.callPackageWith (pkgs // self'.__overrides // {inherit callPackage;});
  in
    callPackage ./sbt-derivation.nix {} args;

  inherit (pkgs.callPackage ./sbt-derivation.nix {}) __functionArgs;

  __overrides = {};

  withOverrides = overrides: self // {__overrides = overrides // self.__overrides;};
})
