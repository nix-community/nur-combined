{ pkgs, ... }: {
  programs = {
    fish = {
      enable = true;
      shellAliases = { sudo = "doas"; };
      shellInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      '';
    };

    zoxide.enableFishIntegration = true;
  };
}
