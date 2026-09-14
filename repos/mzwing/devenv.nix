{
  inputs,
  pkgs,
  ...
}: {
  languages.nix = {
    enable = true;
    lsp.enable = true;
  };

  packages =
    (with pkgs; [
      act
      actionlint
      alejandra
      just
      nixd
      ruff
      shellcheck
      shfmt
    ])
    ++ (with inputs.nur-packages.packages.${pkgs.stdenv.hostPlatform.system}; [
      typenix
    ]);

  cachix.pull = ["mzwing"];

  enterTest = ''
    act --version
    actionlint -version
    alejandra --version
    just --version
    nixd --version
    typenix --version
  '';
}
