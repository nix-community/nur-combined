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
    phantomsocks.enable = true;
    # srs.enable = true;
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
      # {
      #   name = "colour";
      #   configFile = config.age.secrets.hyst-az-cli.path;
      # }
    ];

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
