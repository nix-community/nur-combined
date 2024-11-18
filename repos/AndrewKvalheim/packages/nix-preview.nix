{ symlinkJoin
, writeShellApplication

  # Dependencies
, nvd
}:

symlinkJoin {
  name = "nix-preview";
  paths = [
    (writeShellApplication {
      name = "nix-preview-user";
      runtimeInputs = [ nvd ];
      text = ''
        home-manager build --show-trace
        nvd diff "$HOME/.local/state/home-manager/gcroots/current-home" 'result'
        rm 'result'
      '';
    })

    (writeShellApplication {
      name = "nix-preview-system";
      runtimeInputs = [ nvd ];
      text = ''
        sudo nixos-rebuild build --show-trace
        nvd diff '/nix/var/nix/profiles/system' 'result'
        rm 'result'
      '';
    })
  ];
}
