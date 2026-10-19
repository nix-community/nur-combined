{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (builtins) fromJSON readFile;
  cfg = config.abszero.programs.opencode;
in

{
  options.abszero.programs.opencode.enable = mkEnableOption "open AI agent";

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package =
        with pkgs;
        symlinkJoin {
          name = "opencode";
          paths = [ opencode ];
          nativeBuildInputs = [ makeWrapper ];
          postBuild = ''
            wrapProgram "$out/bin/opencode" \
              --set OPENCODE_EXPERIMENTAL_CODE_MODE true \
              --set OPENCODE_DISABLE_LSP_DOWNLOAD true
          '';
          inherit (opencode) meta;
        };
      tui = fromJSON (readFile ./tui.json);
      settings = fromJSON (readFile ./opencode.json);
    };
  };
}
