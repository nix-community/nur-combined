{
  pkgs,
  data,
  config,
  lib,
  ...
}:
{
  # Mobile device.

  system.stateVersion = "23.05"; # Did you read the comment?
  hardware.opengl.driSupport = true;
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  environment.sessionVariables = {
    WLR_RENDERER = "vulkan";
  };
  zramSwap = {
    enable = false;
    swapDevices = 1;
    memoryPercent = 80;
    algorithm = "zstd";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };
  programs.sway.enable = true;

  srv = {
    openssh.enable = true;
    fail2ban.enable = true;
    # coredns.enable = true;
    dae.enable = true;
  };

  services = {
    prometheus.exporters.node = {
      enable = true;
      listenAddress = "0.0.0.0";
      enabledCollectors = [ "systemd" ];
      disabledCollectors = [ "arp" ];
    };

    sing-box.enable = true;

    snapy.instances = [
      {
        name = "persist";
        source = "/persist";
        keep = "2day";
        timerConfig.onCalendar = "*:0/3";
      }
      {
        name = "var";
        source = "/var";
        keep = "7day";
        timerConfig.onCalendar = "daily";
      }
    ];
    tailscale = {
      enable = false;
      openFirewall = true;
    };

    compose-up.instances = [
      # {
      #   name = "nextchat";
      #   workingDirectory = "/home/${user}/Src/ChatGPT-Next-Web";
      #   extraArgs = "chatgpt-next-web";
      # }
    ];

    shadowsocks.instances = [
      {
        name = "kaambl-local";
        configFile = config.age.secrets.ss.path;
      }
    ];
    hysteria.instances = [
      {
        name = "nodens";
        configFile = config.age.secrets.hyst-us-cli.path;
      }
      {
        name = "colour";
        configFile = config.age.secrets.hyst-az-cli.path;
      }
    ];

    phantomsocks = {
      enable = true;
      settings = {
        interfaces = [
          {
            device = "wlan0";
            dns = "tcp://208.67.220.220:5353";
            hint = "w-seq,https,w-md5";
            name = "default";
          }
          {
            device = "wlan0";
            dns = "tcp://208.67.220.220:443";
            hint = "ipv6,w-seq,w-md5";
            name = "v6";
          }
          {
            device = "wlan0";
            dns = "tcp://208.67.220.220:443";
            hint = "df";
            name = "df";
          }
          {
            device = "wlan0";
            dns = "tcp://208.67.220.220:5353";
            hint = "http,ttl";
            name = "http";
            ttl = 15;
          }
        ];
        profiles = [
          (pkgs.writeText "default.conf" ''
            [default]
            google.com=108.177.111.90,108.177.126.90,108.177.127.90,108.177.97.100,142.250.1.90,142.250.112.90,142.250.13.90,142.250.142.90,142.250.145.90,142.250.148.90,142.250.149.90,142.250.152.90,142.250.153.90,142.250.158.90,142.250.176.64,142.250.176.95,142.250.178.160,142.250.178.186,142.250.180.167,142.250.193.216,142.250.27.90,142.251.0.90,142.251.1.90,142.251.111.90,142.251.112.90,142.251.117.90,142.251.12.90,142.251.120.90,142.251.160.90,142.251.161.90,142.251.162.90,142.251.166.90,142.251.167.90,142.251.169.90,142.251.170.90,142.251.18.90,172.217.218.90,172.253.117.90,172.253.63.90,192.178.49.10,192.178.49.174,192.178.49.178,192.178.49.213,192.178.49.24,192.178.50.32,192.178.50.43,192.178.50.64,192.178.50.85,216.239.32.40,64.233.189.191,74.125.137.90,74.125.196.113,142.251.42.228
            ajax.googleapis.com=[google.com]
            .google.com=[google.com]
            .google.com.hk=[google.com]
            .googleusercontent.com=[google.com]
            .ytimg.com=[google.com]
            .youtube.com=[google.com]
            youtube.com=[google.com]
            .youtube-nocookie.com=[google.com]
            youtu.be=[google.com]
            .ggpht.com=[google.com]
            .gstatic.com=[google.com]
            .translate.goog=[google.com]
            blogspot.com=[google.com]
            .blogspot.com=[google.com]
            blogger.com=[google.com]
            .blogger.com=[google.com]
            fonts.googleapis.com=120.253.250.225
            .googleapis.com=[google.com]
            .googleusercontent.com=[google.com]

            [df]
            .mega.nz
            .mega.co.nz
            .mega.io
            mega.nz
            mega.co.nz
            mega.io

            # [v6]
            # .googlevideo.com

            [http]
            ocsp.int-x3.letsencrypt.org
            captive.apple.com
            neverssl.com
            www.msftconnecttest.com
          '')
        ];
        services = [
          {
            address = "127.0.0.1:1681";
            name = "socks";
            protocol = "socks";
          }
        ];
      };
    };

    factorio = {
      enable = false;
      openFirewall = true;
      serverSettingsFile = config.age.secrets.factorio-server.path;
      serverAdminsFile = config.age.secrets.factorio-server.path;
      mods = [
        (
          (pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
            name = "helmod";
            version = "0.12.19";
            src = pkgs.fetchurl {
              url = "https://dl-mod.factorio.com/files/89/c9e3dfbb99555ba24b085c3228a95fc7a9ad6c?secure=kuZjLfCXoc9awR6dgncRrQ,1702896059";
              hash = "sha256-tUMZWQ8snt3y8WUruIN+skvo9M1V8ZhM7H9QNYkALYQ=";
            };
            dontUnpack = true;
            installPhase = ''
              runHook preInstall
              install -m 0644 $src -D $out/helmod_${finalAttrs.version}.zip
              runHook postInstall
            '';
          }))
          // {
            deps = [ ];
          }
        )
      ];
    };

    gvfs.enable = false;
    blueman.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraConfig.pipewire."92-low-latency" = {
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 256;
          default.clock.min-quantum = 256;
          default.clock.max-quantum = 256;
        };
      };
    };
  };

  systemd = {
    enableEmergencyMode = true;
    watchdog = {
      runtimeTime = "20s";
      rebootTime = "30s";
    };
    sleep.extraConfig = ''
      AllowHibernation=no
    '';
  };
  systemd.tmpfiles.rules = [
    # "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    "L+ /run/gdm/.config/monitors.xml - - - - ${pkgs.writeText "gdm-monitors.xml" ''
      <monitors version="2">
          <configuration>
              <logicalmonitor>
                  <x>0</x>
                  <y>0</y>
                  <scale>2</scale>
                  <primary>yes</primary>
                  <monitor>
                      <monitorspec>
                          <connector>eDP-1</connector>
                          <vendor>BOE</vendor>
                          <product>0x0893</product>
                          <serial>0x00000000</serial>
                      </monitorspec>
                      <mode>
                          <width>2160</width>
                          <height>1440</height>
                          <rate>60.001</rate>
                      </mode>
                  </monitor>
              </logicalmonitor>
          </configuration>
      </monitors>
    ''}"
  ];
}
