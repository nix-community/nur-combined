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
        nom-home-manager build --show-trace "$@"
        nvd diff "$HOME/.local/state/home-manager/gcroots/current-home" 'result'
        rm 'result'
      '';
    })

    (writeShellApplication {
      name = "nix-preview-system";
      runtimeInputs = [ nom-wrappers nvd ];
      text = ''
        sudo nom-nixos-rebuild build --show-trace "$@"
        nvd diff '/nix/var/nix/profiles/system' 'result'
        rm 'result'
      '';
    })
  ];
}
