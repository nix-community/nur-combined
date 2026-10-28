{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "7b4ba77507d2745a9060e33bce7db69439ed9e3f";
  sha256 = "sha256-9SAvs6yAvwPBgsdGSOB8VNpIi1uvOepeuC9gnLVO6wI=";
  version = "unstable-2026-10-26";
  branch = "staging-nixos";
}
