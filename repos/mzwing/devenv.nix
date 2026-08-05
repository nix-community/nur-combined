{
  inputs,
  pkgs,
  ...
}: {
  overlays = [inputs.nur.overlays.default];

  languages.nix = {
    enable = true;
    lsp.enable = true;
  };

  packages = with pkgs; [
    act
    actionlint
    alejandra
    just
    nixd
    ruff
    ty
    nur.repos.mzwing.typenix
  ];

  enterTest = ''
    act --version
    actionlint -version
    alejandra --version
    just --version
    nixd --version
    typenix --version
  '';
}
