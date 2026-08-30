{
  home-manager.sharedModules = [
    ({
      lib,
      pkgs,
      ...
    }: {
      home = {
        packages = [pkgs.vscode-fhs];

        activation.vscodeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
          vs_dir="$HOME/Configs/vs-codium"

          for vs_file in settings.json keybindings.json; do
            if [ ! -f "$vs_dir/$vs_file" ]; then
              echo "VS Code configuration file not found: $vs_dir/$vs_file" >&2
              exit 1
            fi
          done

          mkdir -p "$HOME/.config/Code/User"

          vs_dst="$HOME/.config/Code/User/settings.json"
          if [ -e "$vs_dst" ] && [ ! -L "$vs_dst" ]; then
            echo "Refusing to replace non-symlink VS Code configuration: $vs_dst" >&2
            exit 1
          fi

          ln -sfn "$vs_dir/settings.json" "$vs_dst"
        '';

        activation.vscodeKeybindings = lib.hm.dag.entryAfter ["vscodeSettings"] ''
          vs_dir="$HOME/Configs/vs-codium"
          user_dir="$HOME/.config/Code/User"
          profiles_dir="$user_dir/profiles"

          if [ ! -f "$vs_dir/keybindings.json" ]; then
            echo "VS Code keybindings file not found: $vs_dir/keybindings.json" >&2
            exit 1
          fi

          mkdir -p "$profiles_dir"

          if [ -e "$user_dir/keybindings.json" ] && [ ! -L "$user_dir/keybindings.json" ]; then
            echo "Refusing to replace non-symlink VS Code keybindings: $user_dir/keybindings.json" >&2
            exit 1
          fi

          ln -sfn "$vs_dir/keybindings.json" "$user_dir/keybindings.json"

          for profile in "$profiles_dir"/*; do
            if [ -d "$profile" ]; then
              if [ -e "$profile/keybindings.json" ] && [ ! -L "$profile/keybindings.json" ]; then
                echo "Refusing to replace non-symlink VS Code profile keybindings: $profile/keybindings.json" >&2
                exit 1
              fi

              ln -sfn "$vs_dir/keybindings.json" "$profile/keybindings.json"
            fi
          done
        '';
      };
    })
  ];
}
