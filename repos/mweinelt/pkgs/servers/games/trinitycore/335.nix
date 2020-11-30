{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.20111";
  sha256 = "1i8gs2samas9d57xk9gslcxm2aadzqkk4s3aiyzd6q9b0w0spg1b";
})
