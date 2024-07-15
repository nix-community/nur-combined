{ callPackage
, fetchFromGitea
}:
let
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "uninsane";
    rev = "e6f88f563bdd1700c04018951de4f69862646dd1";
    hash = "sha256-h1EdA/h74zgNPNEYbH+0mgOMlJgLVcxuZ8/ewsZlgEc=";
  };
in callPackage "${src}/default.nix" { }
