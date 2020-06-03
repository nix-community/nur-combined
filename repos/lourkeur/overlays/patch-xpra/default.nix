self: super:
let
  branch = self.fetchFromGitHub {
    owner = "lourkeur";
    repo = "nixpkgs";
    rev = "2be0d21958b1e8594c295b268d4e8103f99f8619";
    sha256 = "0rdaqrz7lchmsp4bnhz2ppdr2kl1dmz5jjdq6c2zmcv2q8pjvpdr";
  };
in {
  xpra = self.callPackage "${branch}/pkgs/tools/X11/xpra" { };
}
