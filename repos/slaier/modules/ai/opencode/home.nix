{ pkgs, ... }:
let
  i-have-adhd = pkgs.fetchFromGitHub {
    owner = "ayghri";
    repo = "i-have-adhd";
    rev = "b15d0be58f55b33972ba3e39709e0e5208ef30cb";
    hash = "sha256-wnD5crIal23Vtk6GReG2vCkjDuhrpmhWXvrNUq5mZfE=";
  };
in
{
  programs.opencode = {
    enable = true;
    skills.skill-creator = ./skills/skill-creator;
    extraPackages = with pkgs; [ rtk ];
    settings = {
      plugin = [
        "${pkgs.rtk.src}/hooks/opencode/rtk.ts"
        "@dietrichgebert/ponytail"
        "${i-have-adhd}/.opencode/plugins/i-have-adhd.mjs"
      ];
      permission = {
        read = {
          "secrets/**" = "deny";
        };
      };
    };
  };
}
