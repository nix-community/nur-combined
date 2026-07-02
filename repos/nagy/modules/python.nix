{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.types) listOf package functionTo;
  cfg = config.nagy.python;

  defaultPackages = ps: [
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

    # Misc
    (ps.callPackage ../pkgs/python3-packages/tvdatafeed.nix { })
    (ps.callPackage ../pkgs/python3-packages/ta-lib.nix { })
    (ps.callPackage ../pkgs/python3-packages/mintalib.nix { })
  ];
in
{
  options.nagy.python = {

    extraPackages = lib.mkOption {
      type = functionTo (listOf package);
      default = ps: [ ];
      example = lib.literalExpression ''
        ps: [
          ps.requests
          ps.flask
        ]
      '';
      description = ''
        Extra Python packages.  Receives `ps`, returns a list of
        derivations.  Lists from multiple modules are concatenated.
      '';
    };

  };
  config = {
    environment.systemPackages = [
      (pkgs.python3.withPackages (ps: (defaultPackages ps) ++ (cfg.extraPackages ps)))
      pkgs.black
      pkgs.isort
      pkgs.pyright

      pkgs.uv
      pkgs.ruff
      pkgs.ty
    ];
  };
}
