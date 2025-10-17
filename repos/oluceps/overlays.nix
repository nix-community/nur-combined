{ inputs', inputs }:
# Go: https://github.com/NixOS/nixpkgs/issues/86349#issuecomment-624489806
# Rust:
(inputs.self.lib.genOverlays [
  "fenix"
  "nuenv"
  "dae"
  "niri"
  "devenv"
])
++ [
  (
    final: prev:
    prev.lib.genAttrs [
      "prismlauncher"
      "resign"
      "nix-direnv"
      # "radicle"
      "xwayland-satellite"
      "atuin"
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
      inherit (inputs'.nixpkgs-stable.legacyPackages) meilisearch minio;
      # inherit (inputs'.nixpkgs-master.legacyPackages) linuxPackages_latest;
      tuwunel = inputs'.conduit.packages.default;

      sing-box = prev.sing-box.overrideAttrs (old: rec {
        version = "v1.12.0-beta.24-patch";

        src = prev.fetchFromGitHub {
          owner = "SagerNet";
          repo = "sing-box";
          rev = "1c597d1f5f3fc35b66b3bebbd874a1b02fd8dea1";
          hash = "sha256-OgNb1vjNazZb2zLACJW8mobALXkjtPIdxz/jdRcD8H0=";
        };
        vendorHash = "sha256-5M7W+cPijIPfnyW3KLdmB0xgE+whdI4J4s6F5kRzGl4=";
        tags = [
          "with_gvisor"
          "with_quic"
          "with_dhcp"
          "with_wireguard"
          "with_utls"
          # "with_acme"
          "with_clash_api"
        ];
        postfixup = ''
          install -Dm444 release/config/sing-box-split-dns.xml -t $out/share/dbus-1/system.d/sing-box-split-dns.conf
        '';
      });

      # misskey = prev.misskey.overrideAttrs (old: {
      #   patches = [
      #     ./pkgs/patch/0001-welcome-shape.patch
      #     ./pkgs/patch/0002-timeline-on-welcome-page.patch
      #   ];
      # });
      # gtk4 = (
      #   prev.gtk4.overrideAttrs (
      #     old:
      #     let
      #       version = "4.18.4";
      #     in
      #     {
      #       inherit version;
      #       src = prev.fetchurl {
      #         url =
      #           let
      #             inherit (prev) lib;
      #           in
      #           "mirror://gnome/sources/gtk/${lib.versions.majorMinor version}/gtk-${version}.tar.xz";
      #         hash = "sha256-1Hg6wVA3wsQnWo8azJT1/t4opRYkP8y5L/VKEcFXdf8=";
      #       };
      #       outputs = [
      #         "out"
      #         "dev"
      #       ];
      #       patches = [ ];
      #       postFixup = ''
      #         demos=(gtk4-demo gtk4-demo-application gtk4-widget-factory)

      #         for program in ''${demos[@]}; do
      #           wrapProgram $dev/bin/$program \
      #             --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH:$out/share/gsettings-schemas/gtk4-${version}"
      #         done
      #       '';
      #     }
      #   )
      # );
      bees = prev.bees.overrideAttrs (
        old:
        (
          let
            version = "0.11-rc4";
          in
          {
            inherit version;
            src = prev.fetchFromGitHub {
              owner = "Zygo";
              repo = "bees";
              rev = "v${version}";
              hash = "sha256-xhtsZxxaJGggeekcSzscqOWceFedL6WIpLr7t2Ea5F0=";
            };
          }
        )
      );

      scx = inputs'.nyx.packages.scx-full_git;

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
