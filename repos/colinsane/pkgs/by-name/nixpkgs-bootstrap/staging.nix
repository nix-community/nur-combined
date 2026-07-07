{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "d1e40d5bca7fed7dd08cae5a85aa95e71b9e4c53";
  sha256 = "sha256-7bbuj83s5aZTZ7glyiHhMWx3h21EmTCoYPEB6gGyxdc=";
  version = "unstable-2026-07-07";
  branch = "staging";
}
