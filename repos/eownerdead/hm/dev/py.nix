{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.eownerdead.dev.py.enable =
    lib.mkEnableOption "Enable Python develop tools";

  config = lib.mkIf config.eownerdead.dev.py.enable {
    home.packages =
      with pkgs;
      [
        python3
        ruff
        mypy
      ]
      ++ (with python3Packages; [
        python-lsp-server
        pylsp-mypy
        pylsp-rope
        python-lsp-ruff
      ]);
  };
}
