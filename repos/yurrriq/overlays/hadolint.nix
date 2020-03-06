self: super: {

  haskellPackages = super.haskellPackages.override {
    overrides = hself: hsuper: {
      hadolint = hself.callPackage ../pkgs/development/haskell-modules/hadolint {};
      language-docker = hself.callPackage ../pkgs/development/haskell-modules/language-docker {};
    };
  };

}
