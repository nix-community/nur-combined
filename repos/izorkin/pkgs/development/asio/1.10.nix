{ callPackage, ... }@args:

callPackage ./generic.nix (
  args
  // {
    version = "1.10.8";
    sha256 = "sha256-Jt7trrvtBiFBeG24z85U538GWIN00IzM8RwC3h2h7Uk=";
  }
)
