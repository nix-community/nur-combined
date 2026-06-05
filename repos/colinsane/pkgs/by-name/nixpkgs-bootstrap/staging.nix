{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "f7121a111f270fc56f3a18a7f6f18c7a11b91737";
  sha256 = "sha256-5/lJ7ABv6gBfH0syuO/hm+p4441y7ykxZ90Py0rLxaY=";
  version = "unstable-2026-06-05";
  branch = "staging";
}
