{
  kdePackages,
  stdenv,
  llvmPackages_19,
}:
kdePackages.callPackage ./default.nix {
  stdenv = if stdenv.hostPlatform.isDarwin then llvmPackages_19.stdenv else stdenv;
}
