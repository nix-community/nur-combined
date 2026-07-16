{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b249ced44a8dff4b50f9674eefb034f5dab51852";
  sha256 = "sha256-jJypTZ8mvZQbjw538NSBDtcS9mqqTmMJIE4jVI455/I=";
  version = "unstable-2026-07-10";
  branch = "staging";
}
