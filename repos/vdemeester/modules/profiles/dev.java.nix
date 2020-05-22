{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.dev.java;
in
{
  options = {
    profiles.dev.java = {
      enable = mkEnableOption "Enable java development profile";
      javaPackage = mkOption {
        default = pkgs.jdk;
        description = "Java package to use";
        type = types.package;
      };
      idea = mkEnableOption "Install intellij idea";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      profiles.dev.enable = true;
      home.packages = with pkgs; [
        cfg.javaPackage
        gradle
      ];
    }
    (
      mkIf cfg.idea {
        home.packages = with pkgs; [ jetbrains.idea-ultimate ];
      }
    )
  ]);
}
