{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "isponsorblocktv";
  cfg = config.homelab.services.${service};
  hl = config.homelab;

  configJson = {
    devices = map (d: {
      screen_id = d.screenId;
      inherit (d) name;
      inherit (d) offset;
    }) cfg.devices;
    inherit (cfg) apikey;
    skip_categories = cfg.skipCategories;
    channel_whitelist = cfg.channelWhitelist;
    skip_count_tracking = cfg.skipCountTracking;
    mute_ads = cfg.muteAds;
    skip_ads = cfg.skipAds;
    minimum_skip_length = cfg.minimumSkipLength;
    auto_play = cfg.autoPlay;
    join_name = cfg.joinName;
    use_proxy = cfg.useProxy;
    sponsorblock_api_url = cfg.sponsorblockApiUrl;
  };
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "iSponsorBlockTV, a SponsorBlock client for YouTube TV apps";

    devices = lib.mkOption {
      default = [ ];
      description = ''
        TVs to connect to. Pair each one locally first (e.g. `nix run
        nixpkgs#isponsorblocktv -- --setup-cli`, found in Settings - Link
        with TV code on the TV) to obtain its screen_id, then pass it here
        as config.sops.placeholder.<name> rather than inline -- it's a
        bearer token that grants control of the TV's YouTube app.
      '';
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            screenId = lib.mkOption {
              type = lib.types.str;
              description = "Pairing screen_id obtained via --setup-cli, e.g. config.sops.placeholder.\"isponsorblocktv-<name>-screen-id\"";
            };
            name = lib.mkOption {
              type = lib.types.str;
              description = "Friendly name for this device";
            };
            offset = lib.mkOption {
              type = lib.types.int;
              default = 0;
              description = "Segment skip offset in seconds";
            };
          };
        }
      );
    };
    apikey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "YouTube API key, only needed for the channel whitelist feature, e.g. config.sops.placeholder.isponsorblocktv-apikey";
    };
    skipCategories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "sponsor" ];
      description = "SponsorBlock categories to skip";
    };
    channelWhitelist = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Channel IDs excluded from ad blocking";
    };
    skipCountTracking = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    muteAds = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically mute native YouTube ads";
    };
    skipAds = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically skip native YouTube ads";
    };
    minimumSkipLength = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "Minimum segment length in seconds to skip";
    };
    autoPlay = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    joinName = lib.mkOption {
      type = lib.types.str;
      default = "iSponsorBlockTV";
      description = "Name shown on the TV when this client connects";
    };
    useProxy = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    sponsorblockApiUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://sponsor.ajay.app/api/";
    };
  };

  config = lib.mkIf cfg.enable {
    # Two of isponsorblocktv's python3.14 dependencies are currently broken
    # upstream in nixpkgs:
    #  - ssdp's test suite fails because it expects the optional `cli`
    #    extra to be installed, so its checks are skipped;
    #  - textual-slider's pyproject.toml version (0.2.0) doesn't match its
    #    dist METADATA (0.1.2), which pythonMetadataCheckPhase rejects, so
    #    that check is skipped too.
    nixpkgs.overlays = [
      (_final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (_pyFinal: pyPrev: {
            ssdp = pyPrev.ssdp.overridePythonAttrs (_old: {
              doCheck = false;
            });
            textual-slider = pyPrev.textual-slider.overridePythonAttrs (_old: {
              dontCheckPythonMetadata = true;
            });
          })
        ];
      })
    ];

    # apikey/screen_id are secrets (bearer tokens), so the config is
    # rendered via a sops template and handed to the service as a
    # LoadCredential -- sops placeholders only get substituted inside
    # declared templates, never inside arbitrary Nix-store paths.
    sops.templates."isponsorblocktv-config.json" = {
      content = builtins.toJSON configJson;
    };

    systemd.services.${service} = {
      description = "iSponsorBlockTV";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        LoadCredential = [
          "config.json:${config.sops.templates."isponsorblocktv-config.json".path}"
        ];
        ExecStart = "${lib.getExe pkgs.isponsorblocktv} --data %d start";
        Restart = "on-failure";
        RestartSec = 10;
      };

      unitConfig = lib.optionalAttrs (hl.notifications.ntfySecretsFile != null) {
        OnFailure = "notify-failure@%n.service";
      };
    };
  };
}
