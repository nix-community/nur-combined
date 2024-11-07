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
      sbctl = (
        prev.callPackage "${prev.path}/pkgs/by-name/sb/sbctl/package.nix" {
          buildGoModule =
            args:
            prev.buildGoModule (
              args
              // (
                let
                  version =
                    let
                      myVersion = "0.16";
                      inherit (prev.lib) versionOlder;
                    in
                    (if (versionOlder myVersion prev.pkgs.sbctl.version) then throw "Newer in nixpkgs" else myVersion);
                in
                {
                  inherit version;

                  src = prev.fetchFromGitHub {
                    owner = "Foxboron";
                    repo = "sbctl";
                    rev = version;
                    hash = "sha256-BLSvjo6GCqpECJPJtQ6C2zEz1p03uyvxTYa+DoxZ78s=";
                  };
                  ldflags = [
                    "-s"
                    "-w"
                    "-X github.com/foxboron/sbctl.Version=${version}"
                  ];
                  patches = [ ];
                  vendorHash = "sha256-srfZ+TD93szabegwtzLTjB+uo8aj8mB4ecQ9m8er00A=";
                  doCheck = false;
                }
              )
            );
        }
      );

      inherit (inputs'.browser-previews.packages) google-chrome-beta;

      # helix = prev.helix.override {
      #   includeGrammarIf =
      #     grammar:
      #     prev.lib.any (name: grammar.name == name) [
      #       "toml"
      #       "rust"
      #       "nix"
      #       "lua"
      #       "make"
      #       "protobuf"
      #       "yaml"
      #       "json"
      #       "markdown"
      #       "html"
      #       "css"
      #       "tsx"
      #       "jsx"
      #       "zig"
      #       "c"
      #       "cpp"
      #       "go"
      #       "python"
      #       "bash"
      #       "kotlin"
      #       "fish"
      #       "javascript"
      #       "typescript"
      #       "sway"
      #       "diff"
      #       "comment"
      #       "vue"
      #       "nu"
      #       "typst"
      #       "scheme"
      #       "just"
      #     ];
      # };

      # sha256 = "0000000000000000000000000000000000000000000000000000";

      scx = inputs'.nyx.packages.scx;

      picom = prev.picom.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "yshui";
          repo = "picom";
          rev = "0fe4e0a1d4e2c77efac632b15f9a911e47fbadf3";
          sha256 = "sha256-daLb7ebMVeL+f8WydH4DONkUA+0D6d+v+pohJb2qjOo=";
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
