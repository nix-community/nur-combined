{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "4589a4e714abf63284cc70b3cf63a81646cfcd04";
  sha256 = "sha256-n+ie9CTuR6tUNQCNs3sMd/Oggk9bzY5LrEpdQCBNNts=";
  version = "unstable-2026-11-06";
  branch = "staging";
}
