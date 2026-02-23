{ config, lib, ... }:
let
  cfg = config.programs.bash;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash = {
      initExtra = ''
        set -o vi
        set completion-ignore-case on
      '';
      profileExtra = ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
        if [ -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh; fi

        nix_paths=("${lib.concatStringsSep "\" \"" config.home.sessionPath}")
        IFS=':'
        read -r -a pre_paths <<< "$PATH"
        paths_to_export=()
        for path in "''${pre_paths[@]}"; do
            if [[ -d "$path" && ! " ''${nix_paths[@]} " =~ " ''${path} " ]]; then
                paths_to_export+=("$path")
            fi
        done
        for path in "''${nix_paths[@]}"; do
            if [[ -d "$path" ]]; then
                paths_to_export+=("$path")
            fi
        done
        export PATH="''${paths_to_export[*]}"
        unset IFS
      '';
    };
  };
}
