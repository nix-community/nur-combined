{
  pkgs,
  ...
}:
{
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";

    nativeBuildInputs = with pkgs; [
      nix
      nixd
      nixfmt
      cachix
      patchelf
      nurl
      nix-update
      nix-output-monitor
      jq
    ];
  };
}
