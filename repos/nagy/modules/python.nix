{
  config,
  pkgs,
  lib,
  # nur,
  ...
}:

let
  cfg = config.nagy.python;
in
{

  options.nagy.python = {
    enable = lib.mkEnableOption "python config";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.python3.withPackages (ps: [
        # Ergonomic
        ps.hy
        ps.hyrule
        ps.addict

        # Numbers
        ps.numpy
        ps.pandas
        ps.pyyaml
        ps.base58
        ps.pyarrow

        # Banking
        ps.schwifty

        # Typst
        ps.typst
      ]))
      pkgs.black
      pkgs.isort
      pkgs.pyright

      pkgs.uv
      pkgs.ruff
      pkgs.ty
    ];
  };
}
