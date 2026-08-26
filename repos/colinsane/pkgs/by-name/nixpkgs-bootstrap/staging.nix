{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "4f05232afc56ca06833286c25ddba76a5d1b2678";
  sha256 = "sha256-XtJj869rAZV6us3MIQvUpsKevQ2NxNAYJUP/5Dw1Gag=";
  version = "unstable-2026-08-25";
  branch = "staging";
}
