{ config, lib, pkgs, utils, ... }:

with lib;

let

  cfg = config.programs.hostapd;
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;

  escapedInterface = cfg: utils.escapeSystemdPath cfg.interface;

  configFile = cfg: pkgs.writeText "hostapd.conf" (''
    interface=${cfg.interface}
    driver=${cfg.driver}
    ssid=${cfg.ssid}
    hw_mode=${cfg.hwMode}
    channel=${toString cfg.channel}
    ${optionalString (cfg.countryCode != null) "country_code=${cfg.countryCode}"}
    ${optionalString (cfg.countryCode != null) "ieee80211d=1"}

    # logging (debug level)
    logger_syslog=-1
    logger_syslog_level=${toString cfg.logLevel}
    logger_stdout=-1
    logger_stdout_level=${toString cfg.logLevel}

    ctrl_interface=/run/hostapd
    ctrl_interface_group=${cfg.group}

    ${optionalString cfg.wpa ''
      wpa=2
      wpa_passphrase=${cfg.wpaPassphrase}
    ''}
    ${optionalString cfg.noScan "noscan=1"}

    ${cfg.extraConfig}

    ${cfg.extraCommonConfig}

  '' + optionalString (cfg.bss != null) ''
    bss=${cfg.bss.interface}
    ssid=${cfg.bss.ssid}
    ${optionalString cfg.wpa ''
      wpa=2
      wpa_passphrase=${cfg.bss.wpaPassphrase}
    ''}
    ${cfg.extraCommonConfig}
  '');

  hostapd_sh = pkgs.writeScriptBin "hostapd.sh" (readFile ./hostapd.sh);

in

{
  ###### interface

  options = {

    programs.hostapd = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable putting a wireless interface into infrastructure mode,
          allowing other wireless devices to associate with the wireless
          interface and do wireless networking. A simple access point will
          <option>enable hostapd.wpa</option>,
          <option>hostapd.wpaPassphrase</option>, and
          <option>hostapd.ssid</option>, as well as DHCP on the wireless
          interface to provide IP addresses to the associated stations, and
          NAT (from the wireless interface to an upstream interface).
        '';
      };

      hostapds = mkOption {
        type = types.attrsOf (types.submodule {
          options = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable putting a wireless interface into infrastructure mode,
          allowing other wireless devices to associate with the wireless
          interface and do wireless networking. A simple access point will
          <option>enable hostapd.wpa</option>,
          <option>hostapd.wpaPassphrase</option>, and
          <option>hostapd.ssid</option>, as well as DHCP on the wireless
          interface to provide IP addresses to the associated stations, and
          NAT (from the wireless interface to an upstream interface).
        '';
      };

      interface = mkOption {
        default = "";
        example = "wlp2s0";
        type = types.str;
        description = ''
          The interfaces <command>hostapd</command> will use.
        '';
      };

      noScan = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Do not scan for overlapping BSSs in HT40+/- mode.
          Caution: turning this on will violate regulatory requirements!
        '';
      };

      driver = mkOption {
        default = "nl80211";
        example = "hostapd";
        type = types.str;
        description = ''
          Which driver <command>hostapd</command> will use.
          Most applications will probably use the default.
        '';
      };

      ssid = mkOption {
        default = "nixos";
        example = "mySpecialSSID";
        type = types.str;
        description = "SSID to be used in IEEE 802.11 management frames.";
      };

      hwMode = mkOption {
        default = "g";
        type = types.enum [ "a" "b" "g" ];
        description = ''
          Operation mode.
          (a = IEEE 802.11a, b = IEEE 802.11b, g = IEEE 802.11g).
        '';
      };

      channel = mkOption {
        default = 7;
        example = 11;
        type = types.int;
        description = ''
          Channel number (IEEE 802.11)
          Please note that some drivers do not use this value from
          <command>hostapd</command> and the channel will need to be configured
          separately with <command>iwconfig</command>.
        '';
      };

      group = mkOption {
        default = "wheel";
        example = "network";
        type = types.str;
        description = ''
          Members of this group can control <command>hostapd</command>.
        '';
      };

      wpa = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable WPA (IEEE 802.11i/D3.0) to authenticate with the access point.
        '';
      };

      wpaPassphrase = mkOption {
        default = "my_sekret";
        example = "any_64_char_string";
        type = types.str;
        description = ''
          WPA-PSK (pre-shared-key) passphrase. Clients will need this
          passphrase to associate with this access point.
          Warning: This passphrase will get put into a world-readable file in
          the Nix store!
        '';
      };

      logLevel = mkOption {
        default = 2;
        type = types.int;
        description = ''
          Levels (minimum value for logged events):
          0 = verbose debugging
          1 = debugging
          2 = informational messages
          3 = notification
          4 = warning
        '';
      };

      countryCode = mkOption {
        default = null;
        example = "US";
        type = with types; nullOr str;
        description = ''
          Country code (ISO/IEC 3166-1). Used to set regulatory domain.
          Set as needed to indicate country in which device is operating.
          This can limit available channels and transmit power.
          These two octets are used as the first two octets of the Country String
          (dot11CountryString).
          If set this enables IEEE 802.11d. This advertises the countryCode and
          the set of allowed channels and transmit power levels based on the
          regulatory limits.
        '';
      };

      extraConfig = mkOption {
        default = "";
        example = ''
          auth_algo=0
          ieee80211n=1
          ht_capab=[HT40-][SHORT-GI-40][DSSS_CCK-40]
          '';
        type = types.lines;
        description = "Extra configuration options to put in hostapd.conf.";
      };

      extraCommonConfig = mkOption {
        default = "";
        type = types.lines;
      };

      bss = mkOption {
        default = null;
        type = with types; nullOr attrs;
      };

        };
      });
    };

    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages =  [ pkgs.hostapd hostapd_sh ];

    hardware.wirelessRegulatoryDatabase = mkDefault (filterAttrs (n: v: v.countryCode != null) cfg.hostapds != {});

    systemd.services = concatMapAttrs (name: value: ({
      "hostapd-${name}" = {
        description = "hostapd ${name} wireless AP";
        path = [ pkgs.hostapd ];
        after = [ "sys-subsystem-net-devices-${escapedInterface value}.device" ];
        bindsTo = [ "sys-subsystem-net-devices-${escapedInterface value}.device" ];
        requiredBy = [ "network-link-${value.interface}.service" ];
        wantedBy = optional value.enable "multi-user.target";

        serviceConfig =
          { ExecStart = "${pkgs.hostapd}/bin/hostapd ${configFile value}";
            Restart = "always";
          };
       };
    } // optionalAttrs (value.bss != null) {
      "hostapd-bss-${name}" = {
        after = [ "sys-subsystem-net-devices-${value.bss.interface}.device" ];
        bindsTo = [ "sys-subsystem-net-devices-${value.bss.interface}.device" ];
        wantedBy = [ "sys-subsystem-net-devices-${value.bss.interface}.device" ];
        path = with pkgs; [ iproute2 ];
        serviceConfig = {
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "bss-start" ''
            ip addr add ${ip4.toCIDR value.bss.address} dev ${value.bss.interface}
          '';
          ExecStop = pkgs.writeShellScript "bss-stop" ''
          '';
        };
      };
    })
    ) cfg.hostapds;

  };
}
