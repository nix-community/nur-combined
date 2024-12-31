{ inputs', inputs }:
# Go: https://github.com/NixOS/nixpkgs/issues/86349#issuecomment-624489806
# Rust:
(inputs.self.lib.genOverlays [
  "fenix"
  "nuenv"
  "dae"
])
++ [
  (
    final: prev:
    prev.lib.genAttrs [
      "prismlauncher"
      "resign"
      "nix-direnv"
      "radicle"
      "nixd"
    ] (n: inputs'.${n}.packages.default)
    # //
    # GUI applications overlay. for stability
    # prev.lib.genAttrs [ "hyprland" ] (n: (import inputs.nixpkgs-gui { inherit system; }).${n})

    // {
      # inherit
      #   (import inputs.nixpkgs-factorio {
      #     inherit (prev) system;
      #     config.allowUnfree = true;
      #   })
      #   factorio-headless-experimental
      #   ;
      inherit (inputs'.browser-previews.packages) google-chrome-beta;

      inherit (inputs'.nyx.packages) scx;

      gtk4 = prev.gtk4.overrideAttrs (old: {
        src = prev.fetchurl {
          url = "mirror://gnome/sources/gtk/${prev.lib.versions.majorMinor "4.17.2"}/gtk-4.17.2.tar.xz";
          hash = "";
        };
      });

      save-clipboard-to = prev.writeShellScriptBin "save-clipboard-to" ''
        wl-paste > $HOME/Pictures/Screenshots/$(date +'shot_%Y-%m-%d-%H%M%S.png')
      '';
      switch-mute = final.nuenv.writeScriptBin {
        name = "switch-mute";
        script =
          let
            pamixer = prev.lib.getExe prev.pamixer;
          in
          ''
            ${pamixer} --get-mute | str trim | if $in == "false" { ${pamixer} -m } else { ${pamixer} -u }
          '';
      };

      systemd-run-app = prev.writeShellApplication {
        name = "systemd-run-app";
        text = ''
          name=$(${final.uutils-coreutils-noprefix}/bin/basename "$1")
          id=$(${final.openssl}/bin/openssl rand -hex 4)
          exec systemd-run \
            --user \
            --scope \
            --unit "$name-$id" \
            --slice=app \
            --same-dir \
            --collect \
            --property PartOf=graphical-session.target \
            --property After=graphical-session.target \
            -- "$@"
        '';
      };
    }
  )
]
