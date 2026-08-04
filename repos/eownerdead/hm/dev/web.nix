{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.eownerdead.dev.web.enable =
    lib.mkEnableOption "Enable Web develop tools";

  config = lib.mkIf config.eownerdead.dev.web.enable {
    home.packages =
      with pkgs;
      [ pandoc ]
      ++ (with pkgs.nodePackages; [
        prettier
        markdownlint-cli2
        typescript
        typescript-language-server
        vscode-langservers-extracted
        yaml-language-server
      ]);
  };
}
