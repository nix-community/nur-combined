{ symlinkJoin
, writeShellApplication

  # Dependencies
, nom-wrappers
, nvd
}:

symlinkJoin {
  name = "nix-preview";
  paths = [
    (writeShellApplication {
      name = "nix-preview-user";
      runtimeInputs = [ nom-wrappers nvd ];
      text = ''
        dir="$(mktemp --directory)"

        env --chdir="$dir" nom-home-manager build --show-trace "$@"
        nvd diff "$HOME/.local/state/home-manager/gcroots/current-home" "$dir/result"

        rm "$dir/result"
        rmdir "$dir"
      '';
    })

    (writeShellApplication {
      name = "nix-preview-system";
      runtimeInputs = [ nom-wrappers nvd ];
      text = ''
        dir="$(mktemp --directory)"

        env --chdir="$dir" sudo nom-nixos-rebuild build --show-trace "$@"
        nvd diff '/nix/var/nix/profiles/system' "$dir/result"

        rm "$dir/result"
        rmdir "$dir"
      '';
    })
  ];
}
