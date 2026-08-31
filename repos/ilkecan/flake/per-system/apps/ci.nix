{
  pkgs,
}:

pkgs.writeShellApplication {
  name = "ci";

  runtimeInputs = with pkgs; [ nix-fast-build ];

  text = ''
    # `--impure` is needed for `NIXPKGS_ALLOW_UNFREE=1`
    NIXPKGS_ALLOW_UNFREE=1 nix-fast-build --impure --no-nom --skip-cached --cachix-cache ilkecan "$@"
  '';
}
