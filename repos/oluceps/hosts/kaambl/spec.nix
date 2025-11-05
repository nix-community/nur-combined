{
  pkgs,
  config,
  lib,
  user,
  ...
}:
{
  # Mobile device.

  vaultix.templates = {
    hyst-tyo = {
      content =
        config.vaultix.placeholder.hyst-tyo-cli
        + (
          let
            port = toString (lib.conn { }).${config.networking.hostName}.abhoth;
          in
          ''
            socks5:
              listen: 127.0.0.1:1091
            udpForwarding:
            - listen: 127.0.0.1:${port}
              remote: 127.0.0.1:${port}
              timeout: 120s
          ''
        );
      owner = "root";
      group = "users";
      name = "tyo.yaml";
      trim = false;
    };
    # hyst-hk = {
    #   content =
    #     config.vaultix.placeholder.hyst-hk-cli
    #     + (
    #       let
    #         port = toString (lib.conn { }).${config.networking.hostName}.yidhra;
    #       in
    #       ''
    #         socks5:
    #           listen: 127.0.0.1:1092
    #         udpForwarding:
    #         - listen: 127.0.0.1:${port}
    #           remote: 127.0.0.1:${port}
    #           timeout: 120s
    #       ''
    #     );
    #   owner = "root";
    #   group = "users";
    #   name = "hk.yaml";
    #   trim = false;
    # };
  };
  system.stateVersion = "23.05"; # Did you read the comment?
  users.mutableUsers = false;

  users.users.${user}.extraGroups = [ "video" ];
  users.groups.video = { };

  environment.systemPackages = with pkgs; [ texlive.combined.scheme-full ];

  services = {
    userborn.enable = true;
    logind = {
      settings.Login.HandleLidSwitch = "suspend";
      settings.Login.HandlePowerKey = "poweroff"; # it sucks. laptop
      settings.Login.HandlePowerKeyLongPress = "poweroff";
    };
    swayidle.timeouts = lib.mkForce [
      # override poweroffmonitor
      {
        timeout = 900;
        command = "/run/current-system/systemd/bin/systemctl suspend";
      }
    ];

    metrics.enable = true;

    # wg-refresh = {
    #   enable = true;
    #   calendar = "hourly";
    # };
    syncthing = {
      enable = true;
      inherit user;
      openDefaultPorts = true;
    };
    # sing-box.enable = true;
    snapy.instances = [
      {
        name = "persist";
        source = "/persist";
        keep = "2day";
        timerConfig.onCalendar = "*:0/5";
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

    # shadowsocks.instances = [
    #   {
    #     name = "kaambl-local";
    #     configFile = config.vaultix.secrets.ss.path;
    #   }
    # ];

    hysteria.instances = {
      # nodens = {
      #   configFile = config.vaultix.secrets.hyst-us-cli.path;
      #   enable = true;
      # };
      abhoth = {
        enable = true;
        configFile = config.vaultix.templates.hyst-tyo.path;
      };
      # yidhra = {
      #   enable = true;
      #   configFile = config.vaultix.templates.hyst-hk.path;
      # };
    };

    factorio = {
      enable = false;
      openFirewall = true;
      serverSettingsFile = config.vaultix.secrets.factorio-server.path;
      serverAdminsFile = config.vaultix.secrets.factorio-server.path;
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
    # blueman.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # jack.enable = true;
      # extraConfig.pipewire."92-low-latency" = {
      #   context.properties = {
      #     default.clock.rate = 48000;
      #     default.clock.quantum = 256;
      #     default.clock.min-quantum = 256;
      #     default.clock.max-quantum = 256;
      #   };
      # };
    };

  };
  system.etc.overlay = {
    enable = true;
    mutable = false;
  };
  # system.forbiddenDependenciesRegexes = [ "perl" ];
  # environment.etc."resolv.conf".text = ''
  #   nameserver 127.0.0.1
  # '';
  environment.sessionVariables = {
    # WLR_RENDERER = "vulkan";
  };
  zramSwap = {
    enable = false;
    swapDevices = 1;
    memoryPercent = 80;
    algorithm = "zstd";
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };
    settings = {
      trusted-public-keys = [ "cache.nyaw.xyz:wXLX+Wtj9giC/+hybqOEJ4FSZIOgOyk8Q6HJxxcZqKY=" ];
      # enable when not in same network of hastur
      # substituters = [ "https://cache.nyaw.xyz" ];
    };
  };
  programs.sway.enable = false;
  programs.gtklock.enable = true;
  programs.light.enable = true;

  systemd = {

    oomd.enable = lib.mkForce false;
    user.services.add-ssh-keys = {
      script = ''
        eval `${pkgs.openssh}/bin/ssh-agent -s`
        export SSH_ASKPASS_REQUIRE="prefer"
        ${pkgs.openssh}/bin/ssh-add ${config.vaultix.secrets.id_sk.path}
      '';
      wantedBy = [ "default.target" ];
    };

    enableEmergencyMode = true;
    settings.Manager = {
      RebootWatchdogSec = "20s";
      RuntimeWatchdogSec = "30s";
    };
    sleep.extraConfig = ''
      AllowHibernation=no
    '';

    tmpfiles.rules = [
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
  };

  repack = {
    plugIn.enable = true;
    openssh.enable = true;
    fail2ban.enable = true;
    # phantomsocks.enable = true;
    garage.enable = true;
    dae.enable = true;
    dnsproxy = {
      # enable = true;
      lazy = true;
      # loadCert = true;
      extraFlags = [
        "--edns-addr=211.136.150.1"
        # "--ipv6-disabled"
        # "--quic-port=853"
        # "--https-port=843"
        "--http3"
        # "--tls-crt=/run/credentials/dnsproxy.service/nyaw.cert"
        # "--tls-key=/run/credentials/dnsproxy.service/nyaw.key"
      ];
    };
    earlyoom.enable = true;
    arti.enable = false;
    # calibre.enable = true;

    userborn-subid.enable = true;
  };
}
