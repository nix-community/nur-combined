{pkgs, config, lib, ...}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs) writeShellScriptBin;

  cfg = config.programs.hello-world;

  helloworld = writeShellScriptBin "helloworld" ''
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
