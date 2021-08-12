{pkgs, config, lib, ...}:
with lib;
let
  cfg = config.programs.hello-world;
  helloworld = pkgs.writeShellScriptBin "helloworld" ''
    echo Hello, world
  '';
in
{
  options = {
    programs.hello-world = {
      enable = mkEnableOption "Hello world module PoC";
    };
  };
  config = mkIf cfg.enable {
    home.packages = [
      helloworld
    ];
  };
}
