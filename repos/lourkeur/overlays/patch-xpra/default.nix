self: super:
let
  branch = self.fetchzip {
    url = https://github.com/lourkeur/nixpkgs/archive/bb52cbe103363ffd03f707c43ec14dfca0077513.zip;
    sha256 = "01w05z11scmv3frjsqbpff3r3554739zvsj5xrvqba0rck2ad718";
  };
in {
  xpra = self.callPackage "${branch}/pkgs/tools/X11/xpra" { };
}

