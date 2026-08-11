{
  nixpkgs,
  lib,
  fetchFromGitHub,
}:
nixpkgs.mlkit.overrideAttrs (prevAttrs: {
  version = "${prevAttrs.version}-8561fe6";
  src = fetchFromGitHub {
    owner = "melsman";
    repo = "mlkit";
    rev = "8561fe6ad949b84f83e8b78508b720ceccabe902";
    hash = "sha256-aHB+KEEhAsI7H1O1hBiuE4evZvqNsIaX2qSld3ybMuw=";
  };

  meta = prevAttrs.meta // {
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    badPlatforms = [
      "aarch64-linux"
      "aarch64-darwin"
    ];
    timeout = 7200;
  };
})
