{
  pkgs,
  lib,
  ...
}:

{
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
}
