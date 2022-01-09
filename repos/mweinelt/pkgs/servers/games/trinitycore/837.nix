{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB837.20101";
  commit = "f0a87e11f2668fea1eeb453a76ac03520d109029";
  sha256 = "04h5nbimdlzcp268qivcj9c9xk0a92crhasrny47vbalsb3brpam";
})
