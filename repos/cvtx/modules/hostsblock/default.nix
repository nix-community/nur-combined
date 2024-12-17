{ config, lib, pkgs, ... }:

let
  cfg = config.services.hostsblock;
  # Write required files to the Nix store
  defaultHostsFile = pkgs.writeText "default-hosts" cfg.defaultHosts;
  staticHostsFile = pkgs.writeText "static-hosts" cfg.staticHosts;
  urlsFile = pkgs.writeText "hosts-urls" (lib.concatStringsSep "\n" cfg.urls);
in {
  options = {
    services.hostsblock = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the hostsblock service to update /etc/hosts.";
      };

      urls = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
        description = "List of URLs to fetch hosts blocking files.";      
      };

      defaultHosts = lib.mkOption {
        type = lib.types.lines;
        default = ''
          127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
          ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
          ::1         ip6-localhost
          ::1         ip6-loopback
          fe00::0     ip6-localnet
          ff00::0     ip6-mcastprefix
          ff02::1     ip6-allnodes
          ff02::2     ip6-allrouters
          ff02::3     ip6-allhosts
        '';
        description = "Default hosts entries. It's recommended to change staticHosts instead.";
      };

      staticHosts = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Additional static hosts entries.";
        example = ''
          127.0.0.1 example.localhost
          127.0.0.1 test.local
        '';
      };

      updateInterval = lib.mkOption {
        type = lib.types.int;
        default = 24;
        example = 12;
        description = "Interval in hours for periodic updates.";
      };

      onBootDelay = lib.mkOption {
        type = lib.types.int;
        default = 900;
        example = 900; # 15 minutes
        description = "Delay in seconds before the service runs after boot.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Environment setup
    systemd.services.hostsblock = {
      description = "Update the hosts file using custom blocking rules";
      wantedBy = [ "multi-user.target" "network-online.target" ];
      wants = [ "network-online.target" ];
      after = [ "network.target" "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = [
          # Ensure temporary directory is clean and exists
		      "${pkgs.bash}/bin/bash -c 'rm -rf /tmp/hostsblock && mkdir -p /tmp/hostsblock'"
          # Create static hosts file
          "${pkgs.bash}/bin/bash -c 'cat ${defaultHostsFile} ${staticHostsFile} > /tmp/hostsblock/0-default.hosts.tmp'"
          # Download hosts files
          "${pkgs.bash}/bin/bash -c 'cat ${urlsFile} | xargs -n 1 ${pkgs.curl}/bin/curl --fail --silent >> /tmp/hostsblock/1000-web.hosts.tmp'"
          # Concatenate and process
          "${pkgs.bash}/bin/bash -c 'cat /tmp/hostsblock/*.hosts.tmp | sed \"/^[ \\t]*#/d\" | sed -e \"s/[[:space:]]\\+/ /g\" | sort -u > /tmp/hostsblock/hosts'"
          # Move the processed hosts file to /run/hostsblock
          "${pkgs.bash}/bin/bash -c 'mkdir -p /run/hostsblock && mv /tmp/hostsblock/hosts /run/hostsblock/hosts'"
        ];
        Restart = "on-failure";
        Environment = lib.flatten [
          "PATH=${
            lib.makeBinPath [
              pkgs.curl
              pkgs.bash
              pkgs.findutils
              pkgs.coreutils
              pkgs.gnused
            ]
          }"
        ];
        PrivateTmp = true;
      };
    };

    # Timer for periodic updates
    systemd.timers.hostsblock = {
      description = "Timer for hostsblock periodic updates";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnUnitActiveSec = "${toString cfg.updateInterval}h";
        OnBootSec = "${toString cfg.onBootDelay}s";
        Persistent = true;
      };
      unitConfig = {
        Unit = "hostsblock.service";
      };
    };
  };
}
