{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "088e6eb738745a7826ccea23bdae906c4cca1e3a";
  sha256 = "sha256-wW1GWDRp7n8Ad5YO/TlNUghHX3uFdycMuQLAHqpq/os=";
  version = "unstable-2026-09-25";
  branch = "staging-nixos";
}
