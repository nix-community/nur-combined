self: super:
let
  branch = self.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "82ef74d0105bb2ab3ffa0cdccb4713054c5acbe8";
    sha256 = "0pcskqcvfs7knbl6hpqldqi4vrwcp9hg73l99qhhj72v3kglz4ri";
  };
in {
  xpra = self.callPackage "${branch}/pkgs/tools/X11/xpra" { };
}
