{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.my.vscode;
  jsonFormat = pkgs.formats.json { };
in {
  options.my.vscode = {
    package = mkOption {
      type = with types; package;
      default = pkgs.vscodium;
      description = ''
        The vscode package package to use, can be any suitable vscode fork.
        Currently suitably packaged options: vscode, vscode-insiders, vscodium and oni2 (though I haven't tested oni2)'';
      example = literalExpression "pkgs.vscode";
    };

    userSettings = mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = "Settings to apply to Visual Studio Code";
    };

    extensions = mkOption {
      type = with types; listOf package;
      default = [ ];
      example = literalExpression "[ pkgs.vscode-extensions.bbenoist.nix ]";
      description = ''
        The extensions Visual Studio Code should be started with.
      '';
    };
  };
}
