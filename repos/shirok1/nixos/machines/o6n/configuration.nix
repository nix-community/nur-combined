# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../fragments/bbr.nix
    ../../fragments/box64.nix
    ../../fragments/fex.nix
    ../../fragments/nh.nix
    ../../fragments/nix-settings.nix
    ../../fragments/tfo.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.edk2-cix = {
    enable = true;
    product = "orion-o6n";
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.cix-npu-driver = {
    enable = true;
    enableDevfreq = false;
  };

  networking.hostName = "nixo6n"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  # networking.networkmanager.enable = true;
  networking.useDHCP = false;
  systemd.network.enable = true;
  systemd.network = {
    netdevs = {
      "10-bond0" = {
        netdevConfig = {
          Kind = "bond";
          Name = "bond0";
          MACAddress = "00:48:54:20:b7:b2";
        };
        bondConfig = {
          # Mode = "active-backup";
          # Mode = "802.3ad";
          Mode = "balance-xor";
          TransmitHashPolicy = "layer3+4";
        };
      };
      "20-vm0" = {
        netdevConfig = {
          Kind = "macvtap";
          Name = "vm0";
          MACAddress = "00:48:54:20:b7:ff";
        };
      };
    };
    networks = {
      "30-r8169" = {
        matchConfig.Driver = "r8169";
        networkConfig.Bond = "bond0";
      };
      "40-bond0" = {
        matchConfig.Name = "bond0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = "routable";
        macvtap = [ "vm0" ];
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";

  # Configure network proxy if necessary
  #networking.proxy.default = "http://192.168.88.190:6152/";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  zramSwap.enable = true;

  nixpkgs.config.allowUnfree = true;

  documentation.man.cache.enable = false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
      KernelExperimental = true;
    };
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  boot.binfmt.fex = {
    enable = true;
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shiroki = {
    isNormalUser = true;
    linger = true;
    extraGroups = [
      "wheel"
      "audio"
      "video"
      "input"
      "docker"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    packages = with pkgs; [
      tree
      btop
      nurl
      nix-init
      gh
      dua
      dust
      zoxide
      atuin
      eza
      just
      nix-index
      ethtool
      gitui
      dive

      (writeShellScriptBin "stata-mp-box64" ''
        export LD_LIBRARY_PATH="${
          lib.makeLibraryPath [
            zlib
            curl
            ncurses
          ]
        }''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        ${box64}/bin/box64 ${shirok1-x86_64.stata.override { ignoreCurl = true; }}/stata-mp "$@"
      '')
      (writeShellScriptBin "stata-mp-fex" ''
        ${fex}/bin/FEX ${shirok1-x86_64.stata}/stata-mp "$@"
      '')
      nodejs
      ffmpeg
      mosh
      tsshd
      unzip
      upx
      bun
      fd
      p7zip
      file
      llm-agents.codex
      llm-agents.claude-code
      llm-agents.dsh
      llm-agents.opencode
      llm-agents.herdr
      llm-agents.skills

      (ghidra.withExtensions (
        p: with p; [
          findcrypt
          ghidra-firmware-utils
          ghidraninja-ghidra-scripts
          lightkeeper
          ret-sync
          ghidra-golanganalyzerextension
        ]
      ))
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    git
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    helix
    xh
    nixd
    nil
    htop
    jq
    pciutils
    nvme-cli
    usbutils
    tmux
    zellij
    compose2nix
    nixfmt-rs
    (nixfmt-tree.override {
      runtimeInputs = [ nixfmt-rs ];
    })
    binutils
    patchelf
    libtree
    ghostty.terminfo
    lsof
    jdupes
    (lib.getBin pkgs.elfutils)
    uv
    shirok1.futu-opend-rs
  ];

  programs.nix-ld.enable = true;

  environment.etc."vuetorrent".source = "${pkgs.vuetorrent}/share/vuetorrent";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.nexttrace.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.fish.generateCompletions = false;

  virtualisation.docker = {
    enable = true;
    # Set up resource limits
    daemon.settings = {
      experimental = true;
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.avahi = {
    enable = true;
    publish.enable = true;
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "vfs objects" = [
          "fruit"
          "streams_xattr"
        ];
        "fruit:metadata" = "stream";
        "fruit:model" = "AirPort6";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:posix_rename" = "yes";
        "fruit:copyfile" = "yes";
        "kernel oplocks" = "yes";
      };
      homes = {
        "valid users" = "%S, %D%w%S";
        "browseable" = "no";
        "writeable" = "yes";
      };
      EP990 = {
        "path" = "/drive/ep990";
        "browseable" = "yes";
        "writeable" = "yes";
      };
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraSetFlags = [
      "--accept-dns=false"
    ];
  };

  services.daed = {
    enable = true;
    package = pkgs.daed;
    listen = "0.0.0.0:2023";
    openFirewall = {
      enable = true;
      port = 2023;
    };
    assetsPaths =
      let
        combined = pkgs.rules.combined."elysias123/geosite";
      in
      [
        # "${pkgs.v2ray-geoip}/share/v2ray/geoip.dat"
        # "${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat"
        "${combined}/share/v2ray/geoip.dat"
        "${combined}/share/v2ray/geosite.dat"
      ];
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "admin@shiroki.tech";
      extraLegoFlags = [ "--dns.propagation-wait=10s" ];
    };
    certs = {
      "berry.shiroki.tech" = {
        domain = "*.berry.shiroki.tech";
        group = config.services.nginx.group;
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CF_DNS_API_TOKEN_FILE" = config.sops.secrets."acme/cloudflare".path;
        };
        reloadServices = [ "nginx" ];
      };
    };
  };
  sops.secrets."acme/cloudflare" = {
    restartUnits = [ "acme-order-renew-berry.shiroki.tech.service" ];
  };

  services.nginx = {
    enable = true;

    prependConfig = ''
      worker_processes auto;
    '';

    eventsConfig = ''
      use epoll;
    '';

    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    experimentalZstdSettings = true;
    recommendedProxySettings = true;

    commonHttpConfig = ''
      map $http_x_forwarded_for $xff_passthrough {
          default $http_x_forwarded_for;
          ""      $remote_addr;
      }
    '';

    virtualHosts = {
      "ha.berry.shiroki.tech" = {
        addSSL = true;
        acmeRoot = null;
        useACMEHost = "berry.shiroki.tech";
        locations = {
          "/" = {
            proxyPass = "http://[::1]:8123";
            proxyWebsockets = true;
            recommendedProxySettings = false;
            extraConfig = ''
              proxy_buffering off;
              proxy_set_header Host $host;
              # Home Assistant use first untrusted X-Forwarded-For from RIGHT,
              # using $proxy_add_x_forwarded_for will cause CDN IPs treated as client
              proxy_set_header X-Forwarded-For $xff_passthrough;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Server $hostname;
            '';
          };
        };
      };
      "qbt.berry.shiroki.tech" = {
        addSSL = true;
        acmeRoot = null;
        useACMEHost = "berry.shiroki.tech";
        locations = {
          "/" = {
            proxyPass = "http://[::1]:8080";
          };
        };
      };
      "jellyfin.berry.shiroki.tech" = {
        addSSL = true;
        acmeRoot = null;
        useACMEHost = "berry.shiroki.tech";
        locations = {
          "/" = {
            proxyPass = "http://[::1]:8096";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_buffering off;
            '';
          };
        };
      };
    };
  };

  # If you enabled ACME above, configure the email address for registration.
  # Uncomment and set your email if you want automatic Let's Encrypt certs.
  # services.acme = {
  #   acceptTerms = true;
  #   email = "you@example.com";
  #   certs = {
  #     "your.hass.domain" = {
  #       webroot = "/var/www/letsencrypt";
  #     };
  #   };
  # };

  services.nixseparatedebuginfod2.enable = true;

  systemd = {
    packages = [ pkgs.qbittorrent-nox ];
    services."qbittorrent-nox@shiroki" = {
      overrideStrategy = "asDropin";
      wantedBy = [ "multi-user.target" ];
    };
    #settings = {
    #  Manager = { RuntimeWatchdogSec = "30s"; WatchdogDevice = "/dev/watchdog0"; };
    #};
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"

      "apple_tv"
      "bthome"
      "esphome"
      "homekit"
      "homekit_controller"
      "mqtt"
      "mqtt_eventstream"
      "mqtt_json"
      "mqtt_room"
      "mqtt_statestream"
      "nintendo_parental_controls"
      "openai_conversation"
      "open_router"
      "ping"
      "qbittorrent"
      "sleep_as_android"
      "snmp"
      "sonos"
      "steam_online"
      "systemmonitor"
      "tasmota"
      "thread"
      "upnp"
      "waqi"
      "xiaomi_ble"

      "kegtron"
      "ibeacon"

      "ffmpeg"
      "zeroconf"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";

      homeassistant = {
        external_url = "https://ha.berry.shiroki.tech";
      };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };

      sensor =
        let
          snmpAP = {
            platform = "snmp";
            host = "192.168.88.116";
            version = "3";
            username = "!env_var HUAWEI_AP_SNMP_USERNAME";
            auth_key = "!env_var HUAWEI_AP_SNMP_AUTH_KEY";
            auth_protocol = "hmac192-sha256";
            priv_key = "!env_var HUAWEI_AP_SNMP_PRIV_KEY";
            priv_protocol = "aes-cfb-256";
            accept_errors = true;
          };

          apIndex = "232.215.101.161.219.224"; # e8:d7:65:a1:db:e0
          apOid = column: "1.3.6.1.4.1.2011.6.139.13.3.3.1.${toString column}.${apIndex}";
          radioOid =
            column: radio: "1.3.6.1.4.1.2011.6.139.16.1.2.1.${toString column}.${apIndex}.${toString radio}";
          mkSensor = sensor: snmpAP // sensor;
        in
        [
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW Status";
            unique_id = "huawei_ap_status";
            baseoid = apOid 6;
            icon = "mdi:access-point-network";
            value_template = "{% set states = {1: 'idle', 2: 'autofind', 3: 'type_mismatch', 4: 'fault', 5: 'configuring', 6: 'config_failed', 7: 'download', 8: 'normal', 9: 'committing', 10: 'commit_failed', 11: 'standby', 12: 'version_mismatch', 13: 'name_conflict', 14: 'invalid', 15: 'country_code_mismatch'} %} {{ states.get(value | int, 'unknown_' ~ value) }}";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW Uptime";
            unique_id = "huawei_ap_uptime";
            baseoid = apOid 18;
            device_class = "duration";
            unit_of_measurement = "s";
            state_class = "measurement";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW CPU Usage";
            unique_id = "huawei_ap_cpu_usage";
            baseoid = apOid 41;
            unit_of_measurement = "%";
            state_class = "measurement";
            icon = "mdi:cpu-64-bit";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW Memory Usage";
            unique_id = "huawei_ap_memory_usage";
            baseoid = apOid 40;
            unit_of_measurement = "%";
            state_class = "measurement";
            icon = "mdi:memory";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW Temperature";
            unique_id = "huawei_ap_temperature";
            baseoid = apOid 43;
            device_class = "temperature";
            unit_of_measurement = "°C";
            state_class = "measurement";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW Clients";
            unique_id = "huawei_ap_clients";
            baseoid = apOid 44;
            state_class = "measurement";
            icon = "mdi:wifi";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW Firmware";
            unique_id = "huawei_ap_firmware";
            baseoid = apOid 7;
            icon = "mdi:chip";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW Uplink Rate";
            unique_id = "huawei_ap_uplink_rate";
            baseoid = apOid 54;
            device_class = "data_rate";
            unit_of_measurement = "kbit/s";
            state_class = "measurement";
            icon = "mdi:upload-network";
          })

          # Radio 0: 2.4 GHz
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 2.4 GHz Clients";
            unique_id = "huawei_ap_radio_24_clients";
            baseoid = radioOid 40 0;
            state_class = "measurement";
            icon = "mdi:wifi";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 2.4 GHz Channel";
            unique_id = "huawei_ap_radio_24_channel";
            baseoid = radioOid 7 0;
            icon = "mdi:radio-tower";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 2.4 GHz Channel Utilization";
            unique_id = "huawei_ap_radio_24_channel_utilization";
            baseoid = radioOid 25 0;
            unit_of_measurement = "%";
            state_class = "measurement";
            icon = "mdi:chart-donut";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 2.4 GHz Noise";
            unique_id = "huawei_ap_radio_24_noise";
            baseoid = radioOid 24 0;
            device_class = "signal_strength";
            unit_of_measurement = "dBm";
            state_class = "measurement";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 2.4 GHz Average Client Signal";
            unique_id = "huawei_ap_radio_24_average_client_signal";
            baseoid = radioOid 41 0;
            device_class = "signal_strength";
            unit_of_measurement = "dBm";
            state_class = "measurement";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 2.4 GHz Receive Rate";
            unique_id = "huawei_ap_radio_24_receive_rate";
            baseoid = radioOid 32 0;
            device_class = "data_rate";
            unit_of_measurement = "kbit/s";
            state_class = "measurement";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 2.4 GHz Send Rate";
            unique_id = "huawei_ap_radio_24_send_rate";
            baseoid = radioOid 37 0;
            device_class = "data_rate";
            unit_of_measurement = "kbit/s";
            state_class = "measurement";
          })

          # Radio 1: 5 GHz
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 5 GHz Clients";
            unique_id = "huawei_ap_radio_5_clients";
            baseoid = radioOid 40 1;
            state_class = "measurement";
            icon = "mdi:wifi";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 5 GHz Channel";
            unique_id = "huawei_ap_radio_5_channel";
            baseoid = radioOid 7 1;
            icon = "mdi:radio-tower";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 5 GHz Channel Utilization";
            unique_id = "huawei_ap_radio_5_channel_utilization";
            baseoid = radioOid 25 1;
            unit_of_measurement = "%";
            state_class = "measurement";
            icon = "mdi:chart-donut";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 5 GHz Noise";
            unique_id = "huawei_ap_radio_5_noise";
            baseoid = radioOid 24 1;
            device_class = "signal_strength";
            unit_of_measurement = "dBm";
            state_class = "measurement";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 5 GHz Average Client Signal";
            unique_id = "huawei_ap_radio_5_average_client_signal";
            baseoid = radioOid 41 1;
            device_class = "signal_strength";
            unit_of_measurement = "dBm";
            state_class = "measurement";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 5 GHz Receive Rate";
            unique_id = "huawei_ap_radio_5_receive_rate";
            baseoid = radioOid 32 1;
            device_class = "data_rate";
            unit_of_measurement = "kbit/s";
            state_class = "measurement";
          })
          (mkSensor {
            name = "Huawei AirEngine 5762-15HW 5 GHz Send Rate";
            unique_id = "huawei_ap_radio_5_send_rate";
            baseoid = radioOid 37 1;
            device_class = "data_rate";
            unit_of_measurement = "kbit/s";
            state_class = "measurement";
          })
        ];
      script = {
        ir_fan_on_off.alias = "落地扇开关 IR";
        ir_fan_on_off.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SYMPHONY","Bits":12,"Data":"0xD81","DataLSB":"0xB081"}'';
        };
        ir_fan_plus.alias = "落地扇加 IR";
        ir_fan_plus.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SYMPHONY","Bits":12,"Data":"0xDC3","DataLSB":"0xB0C3"}'';
        };
        ir_fan_minus.alias = "落地扇减 IR";
        ir_fan_minus.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SYMPHONY","Bits":12,"Data":"0xDC6","DataLSB":"0xB063"}'';
        };
        ir_fan_swing.alias = "落地扇摇头 IR";
        ir_fan_swing.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SYMPHONY","Bits":12,"Data":"0xD90","DataLSB":"0xB009"}'';
        };
        ir_fan_mode.alias = "落地扇模式 IR";
        ir_fan_mode.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SYMPHONY","Bits":12,"Data":"0xD84","DataLSB":"0xB021"}'';
        };
        ir_ac_light.alias = "空调屏显 IR";
        ir_ac_light.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"COOLIX","Bits":24,"Data":"0xB9F509","DataLSB":"0x9DAF90"}'';
        };
        ir_ac_swing_v_on.alias = "空调上下摆风开 IR";
        ir_ac_swing_v_on.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"COOLIX","Bits":24,"Data":"0xB9F504","DataLSB":"0x9DAF20"}'';
        };
        ir_ac_swing_v_off.alias = "空调上下摆风关 IR";
        ir_ac_swing_v_off.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"COOLIX","Bits":24,"Data":"0xB9F505","DataLSB":"0x9DAFA0"}'';
        };
        ir_ac_swing_h_on.alias = "空调左右摆风开 IR";
        ir_ac_swing_h_on.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"COOLIX","Bits":24,"Data":"0xB9F507","DataLSB":"0x9DAFE0"}'';
        };
        ir_ac_swing_h_off.alias = "空调左右摆风关 IR";
        ir_ac_swing_h_off.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"COOLIX","Bits":24,"Data":"0xB9F508","DataLSB":"0x9DAF10"}'';
        };
        ir_tv_on_off.alias = "电视开关 IR";
        ir_tv_on_off.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x1818D02F","DataLSB":"0x18180BF4"}'';
        };
        ir_tv_input_source.alias = "电视信号源 IR";
        ir_tv_input_source.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x1818A857","DataLSB":"0x181815EA"}'';
        };
        ir_tv_left.alias = "电视左 IR";
        ir_tv_left.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x1818A659","DataLSB":"0x1818659A"}'';
        };
        ir_tv_right.alias = "电视右 IR";
        ir_tv_right.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x1818E619","DataLSB":"0x18186798"}'';
        };
        ir_tv_up.alias = "电视上 IR";
        ir_tv_up.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x181826D9","DataLSB":"0x1818649B"}'';
        };
        ir_tv_down.alias = "电视下 IR";
        ir_tv_down.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x18186699","DataLSB":"0x18186699"}'';
        };
        ir_tv_ok.alias = "电视确定 IR";
        ir_tv_ok.sequence = {
          service = "mqtt.publish";
          data.topic = "cmnd/tasmota_5E6E7B/IrSend";
          data.payload = ''{"Protocol":"SAMSUNG","Bits":32,"Data":"0x181816E9","DataLSB":"0x18186897"}'';
        };
      };
      template = [
        {
          fan = [
            {
              default_entity_id = "fan.ir_fan";
              name = "格力落地扇";
              unique_id = "517d9c34-2f9c-4364-928f-b57449a71f5b";
              optimistic = true;
              turn_on.action = "script.ir_fan_on_off";
              turn_off.action = "script.ir_fan_on_off";
              set_oscillating.action = "script.ir_fan_swing";
            }
          ];
        }
        {
          switch = [
            {
              name = "空调屏显";
              unique_id = "db4fe1d1-c4d8-4218-bf1d-6353a933a3e3";
              optimistic = true;
              turn_on.action = "script.ir_ac_light";
              turn_off.action = "script.ir_ac_light";
            }
            {
              name = "空调上下摆风";
              unique_id = "8ccd543d-bca1-474e-8c0a-16268c1c8fc6";
              optimistic = true;
              turn_on.action = "script.ir_ac_swing_v_on";
              turn_off.action = "script.ir_ac_swing_v_off";
            }
            {
              name = "空调左右摆风";
              unique_id = "25cf3c50-0379-455b-ac13-c8b427f665e6";
              optimistic = true;
              turn_on.action = "script.ir_ac_swing_h_on";
              turn_off.action = "script.ir_ac_swing_h_off";
            }
            {
              name = "电视电源";
              unique_id = "e50aaea2-a3be-4898-939b-e0a3d74d7ac7";
              optimistic = true;
              turn_on.action = "script.ir_tv_on_off";
              turn_off.action = "script.ir_tv_on_off";
            }
          ];
        }
      ];
      climate = [
        {
          platform = "tasmota_irhvac";
          name = "美的空调";
          unique_id = "7798482a-d424-4824-a3ec-7a31e8d3d26f";

          command_topic = "cmnd/tasmota_5E6E7B/IRHVAC";
          state_topic = "stat/tasmota_5E6E7B/RESULT";
          availability_topic = "tele/tasmota_5E6E7B/LWT";

          temperature_sensor = "sensor.wo_shi_daikin_air_sensor_temperature_sensor";
          humidity_sensor = "sensor.wo_shi_daikin_air_sensor_humidity_sensor";

          vendor = "COOLIX";
          mqtt_delay = 0.0;

          min_temp = 16;
          max_temp = 30;
          target_temp = 26;
          initial_operation_mode = "off";
          away_temp = 24;
          precision = 1; # 0.5 fail to send

          supported_modes = [
            "off"
            "auto"
            "cool"
            "dry"
            "heat"
            "fan_only"
          ];

          supported_fan_speeds = [
            "auto" # Auto
            "min" # 20%
            "low" # 40%
            "medium" # 60%
            "high" # 80%
            "max" # 100%
          ];

          supported_swing_list = [
            "off"
            "vertical"
            "horizontal"
            "both"
          ];

          set_swingv = {
            "if".condition = "template";
            "if".value_template = "{{ swingv != 'off' }}";
            "then".action = "script.ir_ac_swing_v_on";
            "else".action = "script.ir_ac_swing_v_off";
          };

          set_swingh = {
            "if".condition = "template";
            "if".value_template = "{{ swingh != 'off' }}";
            "then".action = "script.ir_ac_swing_v_on";
            "else".action = "script.ir_ac_swing_h_off";
          };
        }
      ];
    };
    customComponents = with pkgs.home-assistant-custom-components; [
      pkgs.shirok1.hasscc-tianqi
      (pkgs.shirok1.tasmota-irhvac.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "hristo-atanasov";
          repo = "Tasmota-IRHVAC";
          rev = "pull/190/head";
          hash = "sha256-HlVUVbtbrCFWFlrVtQ+UqET+VpN9fpN261c8OkG1jZU=";
        };
      }))
      (xiaomi_home.overrideAttrs (oldAttrs: {
        # src = inputs.ha-xiaomi-home;
        src = pkgs.fetchFromGitHub {
          owner = "XiaoMi";
          repo = "ha_xiaomi_home";
          rev = "pull/1658/head";
          hash = "sha256-DSPNI/o9P2fu7UgbVvEtv7Uj77p5g5xCgAlFTolh/0o=";
        };
      }))
      pkgs.shirok1.zuyan9-ha-cuk-ble
    ];
  };
  sops.secrets."snmp/auth_key" = { };
  sops.secrets."snmp/priv_key" = { };
  sops.templates."hass.env".content = ''
    HUAWEI_AP_SNMP_USERNAME=hass
    HUAWEI_AP_SNMP_AUTH_KEY=${config.sops.placeholder."snmp/auth_key"}
    HUAWEI_AP_SNMP_PRIV_KEY=${config.sops.placeholder."snmp/priv_key"}
  '';
  systemd.services.home-assistant = {
    serviceConfig = {
      Environment = [
        "OPENAI_BASE_URL=https://api.deepseek.com/v1"
      ];
      EnvironmentFile = [ config.sops.templates."hass.env".path ];
    };
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "shiroki";
  };

  services.clickhouse = {
    enable = false;
    serverConfig = {
      listen_host = "::";
      http_port = 8234;
      tcp_port = 9000;
    };
  };

  services.qui = {
    enable = true;
    openFirewall = true;
    user = "shiroki";
    group = "users";
    settings.host = "0.0.0.0";
    secretFile = config.sops.secrets."qui/secret".path;
  };
  sops.secrets."qui/secret" = { };

  services.qbittorrent-clientblocker = {
    enable = false;
    settings = {
      checkUpdate = false;
      clientType = "qBittorrent";
      clientURL = "http://127.0.0.1:8080/api";
      clientUsername = "shiroki";
    };
  };

  services.snell-server = {
    enable = true;
    settings = {
      listen = "0.0.0.0:13831";
      dns-ip-preference = "default";
      mode = "unshaped";
    };
    sops.psk = "snell/psk";
  };
  sops.secrets."snell/psk" = {
    restartUnits = [ "snell-server.service" ];
  };

  services.peerbanhelper = {
    enable = true;
    jrePackage = pkgs.jdk25_headless;
    jvmOptions = [
      "-Djna.library.path=${pkgs.systemdLibs}/lib"
      "--enable-native-access=ALL-UNNAMED"
      "-XX:+UseStringDeduplication"
      "-XX:+UseCompactObjectHeaders"
      "-XX:+UseZGC -XX:+ZGenerational"
    ];
  };

  programs.osmo-fl2k.enable = true;

  systemd.user.services.mihomo = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.getExe pkgs.mihomo;
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    80
    443
    1883 # MQTT
    5970
    8080
    8234
    9898 # PeerBanHelper
    9000
    13831 # Snell
    8123 # Home Assistant
    21064 # Home Assistant HomeKit Bridge
    1400 # Home Assistant Sonos
    1443 # Home Assistant Sonos
    17650 # mihomo
  ];
  networking.firewall.allowedUDPPorts = [
    161 # SNMP
    162 # SNMP Trap
    5970
    13831 # Snell
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
