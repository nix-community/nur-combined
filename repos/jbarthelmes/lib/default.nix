{ pkgs }:

with pkgs.lib; {
  normalUser = description: extraGroups: extraConfig:
    {
      isNormalUser = true;
      inherit description extraGroups;
    } // extraConfig;
}

