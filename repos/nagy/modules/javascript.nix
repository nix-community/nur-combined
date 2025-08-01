{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nagy.javascript;
in
{
  options.nagy.javascript = {
    enable = lib.mkEnableOption "javascript config";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.nodejs
      pkgs.deno
      pkgs.bun
      pkgs.typescript-language-server
      pkgs.svelte-language-server
    ];

  };
}
