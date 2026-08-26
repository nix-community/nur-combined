{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "6c17a0593637c5147bfd278c4ce083b1c715b576";
  sha256 = "sha256-sMmDR5b5f/pbE6LvMgeiL9iL1RqCxvT+qg+T6MwMqRc=";
  version = "unstable-2026-08-25";
  branch = "staging-next";
}
