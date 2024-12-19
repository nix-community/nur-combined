{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "9e59c661dc1c71ddc76f94105d328a48601cd26f";
  sha256 = "sha256-XyNYKao8hVACA4hgSu4TUPIfHzx+P3bqB4vWyWLHIYM=";
  version = "0-unstable-2024-12-19";
  branch = "staging";
}
