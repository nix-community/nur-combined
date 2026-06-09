{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "000014f950256f038d86923b8499a2da437ed871";
  sha256 = "sha256-PF1Knxjn6VuM6I7WsWKhsGhNdagrO2ZyQ7HleJCHFaQ=";
  version = "unstable-2026-06-09";
  branch = "staging-next";
}
