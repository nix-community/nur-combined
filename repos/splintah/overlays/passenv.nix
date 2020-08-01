# Override haskell, adding passenv.
self: super:
let
  src = fetchTarball {
    url = "https://github.com/splintah/passenv/archive/4128e3588825ebce127fee4dff347e964526ae69.tar.gz";
    sha256 = "18c67wq5w577h2zr8ga7fs8gpr017bwf5gdy7q65hwrbmayc9bvp";
  };
in
{
  haskell = super.haskell // {
    packageOverrides = haskellSelf: haskellSuper: {
      passenv = haskellSelf.callPackage (src + "/passenv.nix") { };
    };
  };
  # haskellPackages = super.haskellPackages.override {
  #   overrides = haskellSelf: haskellSuper: {
  #     passenv = haskellSelf.callPackage (src + "/passenv.nix") { };
  #   };
  # };
}
