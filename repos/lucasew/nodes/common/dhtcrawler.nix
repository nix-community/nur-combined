{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types mkDefault;
  inherit (pkgs) buildGoModule fetchFromGitHub;

  cfg = config.services.dhtcrawler;

  dhtc = buildGoModule {
    pname = "dhtc";
    version = "unstable-2022.10.14";

    preConfigure = ''
      export TEMPLATE_DIR=$out/share/dhtc/templates

      substituteInPlace templates/* \
        --replace 'templates/' "$TEMPLATE_DIR/"

      cat templates/base.html
    '';

    src = fetchFromGitHub {
      owner = "lucasew";
      repo = "dhtc";
      rev = "feat/go-sum";
      sha256 = "sha256-8BzHkyn5pox+2Lfb5nCEpx6sXNasiMjzbDaZ0gn7BUA=";
    };

    subPackages = [ "." ];
    vendorSha256 = "sha256-+sXB1JmYVDxFCapPSZCBIIQX2bnMgc49GfKBIpegdQU=";

    postInstall = ''
      mkdir $TEMPLATE_DIR -p
      install templates/* $TEMPLATE_DIR
    '';
  };
  magnetico = buildGoModule {
    pname = "magnetico";
    version = "0.12.0";

    preConfigure = ''
      go mod download github.com/Wessie/appdirs
    '';

    src = fetchFromGitHub {
      owner = "boramalper";
      repo = "magnetico";
      rev = "5546a941e4f3a2fa6a2bc8bff8876aa69780034b";
      sha256 = "sha256-5hu/FLOZd8rvlppis9ubKo1qJl8vXCuBuQfrtP0ak1E=";
    };
    vendorSha256 = lib.fakeSha256;
  };
in {
  options.services.dhtcrawler = {
    enable = mkEnableOption "dhtcralwer";
    port = mkOption {
      description = "DHT crawler port";
      type = types.port;
      default = 4200;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ magnetico ];
    users = {
      users.dhtc = {
        isSystemUser = true;
        group = "dhtc";
      };
      groups.dhtc = {};
    };
    systemd.services.dhtc = {
      description = "DHT crawler";
      path = with pkgs; [ dhtc nettools ];
      requires = [ "network-online.target" "internetns.service" ];
      restartIfChanged = true;
      serviceConfig = {
        StateDirectory="dhtcrawler";

        # https://gist.github.com/ageis/f5595e59b1cddb1513d1b425a323db04
        # some prefs are stolen from transmission
        User = config.users.users.dhtc.name;
        Group = config.users.users.dhtc.group;
        NetworkNamespacePath="/var/run/netns/internetns";
        DevicePolicy = "closed";
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        # ProtectClock= adds DeviceAllow=char-rtc r
        DeviceAllow = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateNetwork = true;
        PrivateTmp = true;
        # PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
      script = ''
        ifconfig
        echo $STATE_DIRECTORY
        ARGS=( -address :${toString cfg.port} -database $STATE_DIRECTORY -logtostderr -v 10 -crawlerThreads 2)
        echo dhtc "${"$"}{ARGS[@]}"
        dhtc "${"$"}{ARGS[@]}"
      '';
    };
  };
}
