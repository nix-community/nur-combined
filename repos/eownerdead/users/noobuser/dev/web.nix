{ pkgs, ... }: {
  home.packages = with pkgs;
    [ pandoc ] ++ (with pkgs.nodePackages; [
      prettier
      markdownlint-cli2
      typescript
      typescript-language-server
      vscode-langservers-extracted
      yaml-language-server
    ]);
}
