{ callPackage, llvmPackages_4, ... } @ args:

callPackage ./generic.nix {
  # https://github.com/zneak/fcd/releases/tag/llvm-4.0
  # "This release marks the last commit of fcd that is known to build against LLVM 4.0."
  inherit (llvmPackages_4) llvm stdenv;
  rev = "20e121ad7410955a827fb6a56503ff9ce9fe094d";
  sha256 = "1i8wdvfrzvacgankch40fspch92d39bhm1ixl91zjwmp00rgzwk7";
  version = "2017-04-02";
}

