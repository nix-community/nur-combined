{ nix-fast-build, writeShellApplication }:
writeShellApplication {
  name = "check";
  runtimeInputs = [ nix-fast-build ];
  text = "nix-fast-build --skip-cached --no-nom --flake \".#checks.$(nix eval --raw --impure --expr builtins.currentSystem)\"";
}
