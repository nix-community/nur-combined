{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    types
    ;

  cfg = config.programs.glide-browser;
in
{
  options.programs.glide-browser.config = mkOption {
    type = types.lines;
    default = "";
    example = lib.literalExpression ''
      '''
        glide.o.hint_label_generator = glide.hints.label_generators.numeric;
        glide.keymaps.set("normal", "d", "tab_close");
      '''
    '';
    description = ''
      Contents of {file}`$XDG_CONFIG_HOME/glide/glide.ts`.

      This is a TypeScript file evaluated by Glide at startup; see the
      [Glide config documentation](https://glide-browser.app/config) for the
      available API.
    '';
  };

  config = mkIf (cfg.config != "") {
    xdg.configFile."glide/glide.ts".text = cfg.config;
  };
}
