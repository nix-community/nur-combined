{ symlinkJoin
, writeShellApplication

  # Dependencies
, expect
, nix-output-monitor
}:

# Pending maralorn/nix-output-monitor#108
symlinkJoin {
  name = "nom-wrappers";
  paths = [
    (writeShellApplication {
      name = "nom-home-manager";
      runtimeInputs = [ expect nix-output-monitor ];
      text = ''
        case "$1" in
          'build'|'switch') unbuffer home-manager "$1" --log-format 'internal-json' "''${@:2}" |& nom --json;;
          *) exec home-manager "$@";;
        esac
      '';
    })

    (writeShellApplication {
      name = "nom-nixos-rebuild";
      runtimeInputs = [ expect nix-output-monitor ];
      text = ''
        case "$1" in
          'boot'|'build'|'switch'|'test') unbuffer nixos-rebuild "$1" --log-format 'internal-json' --verbose "''${@:2}" |& nom --json;;
          *) exec nixos-rebuild "$@";;
        esac
      '';
    })
  ];
}
