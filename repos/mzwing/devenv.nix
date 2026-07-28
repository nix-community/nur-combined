{
  inputs,
  pkgs,
  ...
}: {
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
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.typenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  enterTest = ''
    act --version
    actionlint -version
    alejandra --version
    which agenix
    just --version
    nixd --version
    typenix --version
  '';
}
