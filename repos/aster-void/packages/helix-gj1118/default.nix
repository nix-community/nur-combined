{
  inputs,
  pkgs,
}:
inputs.helix-gj1118.packages.${pkgs.stdenv.hostPlatform.system}.default
