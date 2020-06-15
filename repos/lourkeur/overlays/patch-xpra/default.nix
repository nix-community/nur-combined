self: super:
let
  branch = self.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "e5b7f1325cca35912144aff3fa822bf930139545";
    sha256 = "0xlkmywz2c2zwky05g9cqi8kpivydvx7n94ggq5nnd5qql2bjbxf";
  };
in {
  xpra = self.callPackage "${branch}/pkgs/tools/X11/xpra" { };
}
