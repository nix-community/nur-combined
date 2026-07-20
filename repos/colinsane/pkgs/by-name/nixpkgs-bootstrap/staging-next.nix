{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "0644f008c052f3db4f729f1af4da30e5b4ea0ea7";
  sha256 = "sha256-5UnsgEG67fX+Jrxp8C+BVfu3FKC327a7r22ftciqmD4=";
  version = "unstable-2026-07-19";
  branch = "staging-next";
}
