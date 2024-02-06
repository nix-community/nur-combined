{ pkgs, ... }: {
  home.packages = with pkgs;
    [ python3 ruff mypy ] ++ (with python3Packages; [
      python-lsp-server
      pylsp-mypy
      pylsp-rope
      python-lsp-ruff
    ]);
}
