{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB335.22011";
  commit = "80e8cbdc96bf0177f5c50c643f7d9003fa93e9f7";
  branch = "3.3.5";
  sha256 = "06y3w2cbxansac974z2v4wdmljgi6kd7bg4m68k1lq9fvc85z5ym";
})
