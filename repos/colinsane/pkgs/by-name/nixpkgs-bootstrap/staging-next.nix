{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "c03fa0c918d4a5de826469f265486888fe5267de";
  sha256 = "sha256-IIrxuRKplK+xD1/41RVDNj8LsaINlQnvvoXiQHafi6M=";
  version = "0-unstable-2024-12-22";
  branch = "staging-next";
}
