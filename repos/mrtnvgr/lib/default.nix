{ pkgs }: rec {
  colors = {
    hex = import ./colors/hex.nix { inherit pkgs; };
  };

  strings = import ./strings.nix { inherit pkgs; };

  numbers = import ./numbers.nix { inherit pkgs; };

  lists = import ./lists.nix { inherit pkgs numbers; };

  mkAudioPluginsPaths = user: format:
    (pkgs.lib.concatStringsSep ":" [
      "/home/${user}/.${format}"
      "/etc/profiles/per-user/${user}/lib/${format}"
      "/home/${user}/.nix-profile/lib/${format}"
      "/run/current-system/sw/lib/${format}"
    ]) + ":";
}
