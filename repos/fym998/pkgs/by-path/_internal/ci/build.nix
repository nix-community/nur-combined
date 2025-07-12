{ writeShellApplication, nix-fast-build }:
writeShellApplication {
  name = "build";

  runtimeInputs = [
    nix-fast-build
  ];

  text = ''
    nix-fast-build \
      --flake ".#ciPackages.$(nix eval --raw --impure --expr builtins.currentSystem)" \
      --no-nom \
      --skip-cached \
      --cachix-cache "$CACHIX_CACHE"
  '';
}
