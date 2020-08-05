# Override haskell, adding passenv.
self: super:
let sources = import ../nix/sources.nix; in
{
  haskell = super.haskell // {
    packageOverrides = haskellSelf: haskellSuper: {
      passenv = haskellSelf.callPackage "${sources.passenv}/passenv.nix" { };
    };
  };
}
