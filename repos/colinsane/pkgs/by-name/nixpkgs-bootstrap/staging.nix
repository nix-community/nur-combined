{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "9f7732b101f3125bf4ceabbf52c0fc077182cab8";
  sha256 = "sha256-ErVdQRrIY0A1BDKqCC1JO27RzvUDLmhdA8l96PQG9gs=";
  version = "unstable-2026-10-10";
  branch = "staging";
}
