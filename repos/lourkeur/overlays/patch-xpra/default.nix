self: super:
let
  branch = self.fetchFromGitHub {
    owner = "mjlbach";
    repo = "nixpkgs";
    rev = "700615f1640d4c86d3f25d4cd3be366da540c566";
    sha256 = "0rdaqrz7lchmsp4bnhz2ppdr2kl1dmz5jjdq6c2zmcv2q8pjvpdr";
  };
in {
  xpra = self.callPackage "${branch}/pkgs/tools/X11/xpra" { };
}

