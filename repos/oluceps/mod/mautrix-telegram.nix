{ inputs, ... }:
{
  flake.modules.nixos.mautrix-telegram =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      fixedPkgs = import inputs.nixpkgs-fix-mautrix {
        system = pkgs.system;
        config.permittedInsecurePackages = [
          "olm-3.2.16"
        ];
      };
      mautrix-telegram-go = pkgs.buildGoModule rec {
        pname = "mautrix-telegram";
        version = "0.2609.0";
        src = pkgs.fetchFromGitHub {
          owner = "mautrix";
          repo = "telegram";
          rev = "v${version}";
          sha256 = "0pc0vnmh5x6vrs7g0qq9vfq6ahiff6r7p3jsnrvihcbqkmm11j9k";
        };
        vendorHash = "sha256-qW/v/QmhQRF2SAMUNXE2mfVGVEp+DU3gESWVRKHqfGM=";
        buildInputs = [ fixedPkgs.olm ];
        ldflags = [
          "-s"
          "-w"
        ];
        doCheck = false;
      };
    in
    {
      vaultix.secrets.mautrix-tg = { };
      systemd.services.mautrix-telegram.serviceConfig.RuntimeMaxSec = 86400;
      services.mautrix-telegram = {
        enable = true;
        package = mautrix-telegram-go;
        environmentFile = config.vaultix.secrets.mautrix-tg.path;
        serviceDependencies = [ "matrix-synapse.service" ];
        settings = {
          homeserver = {
            address = "http://[fdcc::3]:8196";
            domain = "nyaw.xyz";
          };
          appservice = {
            address = "http://127.0.0.1:29317";
            hostname = "127.0.0.1";
            port = 29317;
            # Nullify default python options to prevent mautrix-go legacy config migration
            database = lib.mkForce null;
            database_opts = lib.mkForce null;
          };
          database = {
            type = "postgres";
            uri = "postgres:///mautrix-telegram?host=/run/postgresql";
          };
          bridge = {
            bridge_matrix_leave = false;
            permissions = {
              "*" = "relay";
              "@sec:nyaw.xyz" = "admin";
              "@lyo:nyaw.xyz" = "admin";
            };
            relay = {
              enabled = true;
              user_distinguishers = [ ];
            };
          };
          network = {
            api_id = 611335;
            api_hash = "d524b414d21f4d37f08684c1df41ac9c";
            device_info = {
              app_version = "3.5.2";
            };
            animated_sticker = {
              target = "webp";
              convert_from_webm = true;
            };
            displayname_template = "{{ if .Deleted }}Deleted account {{ .UserID }}{{ else }}{{ .FullName }}{{ end }}";
          };
          logging = {
            min_level = "warn";
            writers = [
              {
                type = "stdout";
                format = "pretty-colored";
              }
            ];
          };
        };
      };
    };
}
