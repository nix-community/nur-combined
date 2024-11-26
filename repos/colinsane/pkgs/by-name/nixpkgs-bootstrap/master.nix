{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "1942e92ea40b1adf4ff399ebe87b37a2121facf0";
  sha256 = "sha256-wwN9Ucg6KaW9GVGOd91TUB9YFqK6Jh5CCSxS9GveJus=";
  version = "0-unstable-2024-11-25";
  branch = "master";
}
