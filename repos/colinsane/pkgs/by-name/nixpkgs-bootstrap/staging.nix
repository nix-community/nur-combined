{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "b4ffcdd28a91b6b7bececfc515aabe44b967454a";
  sha256 = "sha256-KkEi9stQ3R+FNTD2w1QMUrt7JWTkyD6AxzbfcfPx8vE=";
  version = "0-unstable-2024-11-24";
  branch = "staging";
}
