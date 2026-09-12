{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    skills.skill-creator = ./skills/skill-creator;
    extraPackages = with pkgs; [ rtk ];
    settings = {
      plugin = [
        "${pkgs.rtk.src}/hooks/opencode/rtk.ts"
      ];
      permission = {
        read = {
          "secrets/**" = "deny";
        };
      };
    };
  };
}
