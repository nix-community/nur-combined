{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.20111";
  commit = "e6b945eabcdeded8043e40b4e5ede41bd26701dd";
  branch = "3.3.5";
  sha256 = "1i8gs2samas9d57xk9gslcxm2aadzqkk4s3aiyzd6q9b0w0spg1b";
})
