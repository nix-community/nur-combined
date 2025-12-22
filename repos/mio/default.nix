# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> {
    #config.permittedInsecurePackages = [
    #  "qtwebengine-5.15.19"
    #];
    config.allowUnfree = true;
  },
}:
with (import ./private.nix { inherit pkgs; });
let
  self = (
    {
      # note: some packages might be commented out to reduce package numbers. garnix has hardcoded limit of 100.
      # The `lib`, `modules`, and `overlays` names are special
      lib = import ./lib { inherit pkgs; }; # functions
      modules = import ./modules; # NixOS modules
      overlays = import ./overlays; # nixpkgs overlays
    }
    // rec {
      aria2 = v3override (
        pkgs.aria2.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            (pkgs.fetchpatch {
              name = "fix patch aria2 fast.patch";
              url = "https://github.com/agalwood/aria2/commit/baf6f1d02f7f8b81cd45578585bdf1152d81f75f.patch";
              sha256 = "sha256-bLGaVJoHuQk9vCbBg2BOG79swJhU/qHgdkmYJNr7rIQ=";
            })
          ];
        })
      );
      aria2-wrapped = pkgs.writeShellScriptBin "aria2" ''
        ${aria2}/bin/aria2c -s65536 -j65536 -x256 -k1k "$@"
      '';
      caddy =
        let
          # Table mapping caddy source hash + Go version to plugins hash
          # Key format: "<srcHash>:<goVersion>"
          # To check current key: nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; in "${pkgs.caddy.src.outputHash}:${pkgs.caddy.passthru.go.version}"' --raw
          # From local nixpkgs repo: nix eval --impure --expr 'let pkgs = import ./. {}; in "${pkgs.caddy.src.outputHash}:${pkgs.caddy.passthru.go.version}"' --raw
          caddyPluginsHashTable = {
            # nixpkgs-unstable 2025-11-04
            "sha256-KvikafRYPFZ0xCXqDdji1rxlkThEDEOHycK8GP5e8vk=:1.25.2" =
              "sha256-+3itNp/as78n584eDu9byUvH5LQmEsFrX3ELrVjWmEw=";
            # staging-next 20251107
            "sha256-KvikafRYPFZ0xCXqDdji1rxlkThEDEOHycK8GP5e8vk=:1.25.3" =
              "sha256-hfIP97+TKcQkGg6s19VQcz9bS1wqzSBtqVTbtDc4HSQ=";
            # release-25.05 20251107
            "sha256-hzDd2BNTZzjwqhc/STbSAHnNlP7g1cFuMehqU1LumQE=:1.24.9" =
              "sha256-lraVVvjqWpQJmlHhpfWZwC9S0Gvx7nQR6Nzmt0oEOLw=";
            # staging-next 20251116
            "sha256-KvikafRYPFZ0xCXqDdji1rxlkThEDEOHycK8GP5e8vk=:1.25.4" =
              "sha256-cZLVVKeEoSO4im0wGJfwzpAknPs2WFFJpTtDMcaGwhk=";
            # nixos-25.11 20251218
            "sha256-KvikafRYPFZ0xCXqDdji1rxlkThEDEOHycK8GP5e8vk=:1.25.5" =
              "sha256-rNeWnktP6HU+tT10hT6q/ZcIJeJmtu7VFhcXrgcFflM=";
          };
          srcHash = pkgs.caddy.src.outputHash;
          goVersion = pkgs.caddy.passthru.go.version;
          lookupKey = "${srcHash}:${goVersion}";
          pluginsHash =
            caddyPluginsHashTable.${lookupKey}
              or (throw "Unknown caddy source hash + Go version: ${lookupKey}. Please update caddyPluginsHashTable in default.nix");
        in
        (goV3OverrideAttrs pkgs.caddy).withPlugins {
          # https://github.com/crowdsecurity/example-docker-compose/blob/main/caddy/Dockerfile
          # https://github.com/NixOS/nixpkgs/pull/358586
          plugins = [
            "github.com/caddy-dns/cloudflare@v0.2.2"
            "github.com/porech/caddy-maxmind-geolocation@v1.0.1"
            # "github.com/hslatman/caddy-crowdsec-bouncer/http@main"
          ];
          hash = pluginsHash;
        };
      telegram-desktop = pkgs.telegram-desktop.overrideAttrs (old: {
        unwrapped = v3overridegcc (
          old.unwrapped.overrideAttrs (old2: {
            # see https://github.com/Layerex/telegram-desktop-patches
            patches = (pkgs.telegram-desktop.unwrapped.patches or [ ]) ++ [
              ./patches/0001-telegramPatches.patch
            ];
          })
        );
      });
      materialgram = pkgs.materialgram.overrideAttrs (old: {
        unwrapped = v3overridegcc (
          old.unwrapped.overrideAttrs (old2: {
            # see https://github.com/Layerex/telegram-desktop-patches
            patches = (pkgs.materialgram.unwrapped.patches or [ ]) ++ [
              ./patches/0001-materialgramPatches.patch
            ];
          })
        );
      });
      openssh = v3override (
        (pkgs.openssh_10_2 or pkgs.openssh).overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./patches/openssh.patch ];
          #doCheck = false;
        })
      );
      openssh_hpn = v3override (
        pkgs.openssh_hpn.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./patches/openssh.patch ];
        })
      );
      grub2 = nodarwin (
        v3overridegcc (
          pkgs.grub2.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [ ./patches/grub-os-prober-title.patch ];
          })
        )
      );
      bees = nodarwin (v3overridegcc pkgs.bees);
      netdata = (v3override (goV3OverrideAttrs pkgs.netdata)).override { withCloudUi = true; };

      cached = {
        inherit (self)
          aria2-wrapped
          openssh_hpn
          telegram-desktop
          materialgram
          caddy
          lmms
          minetest591client
          minetest580client
          musescore3
          musescore-alex
          tuxguitar
          cb
          beammp-launcher
          mdbook-generate-summary
          #betterbird
          jellyfin-media-player
          eden
          plezy
          downkyicore
          ego
          ;
      };
    }
    // import ./packages.nix { inherit pkgs; }
  );
in
self
