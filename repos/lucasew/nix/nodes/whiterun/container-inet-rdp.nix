{ pkgs, config, ... }:
let
  containerUser = "test";
  super-pkgs = pkgs;
  rdpConfDir =
    let
      cfg = config.containers.chrome-rdp.config.services.xrdp;
    in
    pkgs.runCommand "xrdp.conf" { preferLocalBuild = true; } ''
      mkdir $out

      cp ${cfg.package}/etc/xrdp/{km-*,xrdp,sesman,xrdp_keyboard}.ini $out

      cat > $out/startwm.sh <<EOF
      #!/bin/sh
      . /etc/profile
      ${cfg.defaultWindowManager}
      EOF
      chmod +x $out/startwm.sh

      substituteInPlace $out/xrdp.ini \
        --replace "#rsakeys_ini=" "rsakeys_ini=/run/xrdp/rsakeys.ini" \
        --replace "certificate=" "certificate=${cfg.sslCert}" \
        --replace "key_file=" "key_file=${cfg.sslKey}" \
        --replace LogFile=xrdp.log LogFile=/dev/null \
        --replace EnableSyslog=true EnableSyslog=false

      substituteInPlace $out/sesman.ini \
        --replace LogFile=xrdp-sesman.log LogFile=/dev/null \
        --replace EnableSyslog=1 EnableSyslog=0

      substituteInPlace $out/sesman.ini \
        --replace LogLevel=INFO LogLevel=DEBUG

      # Ensure that clipboard works for non-ASCII characters
      sed -i -e '/.*SessionVariables.*/ a\
      LANG=${config.i18n.defaultLocale}\
      LOCALE_ARCHIVE=${config.i18n.glibcLocales}/lib/locale/locale-archive
      ' $out/sesman.ini
    '';
in
{
  systemd.tmpfiles.rules = [ "d /var/lib/chromerdp-container 0700 root root - -" ];

  containers.chrome-rdp = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.68.1";
    localAddress = "192.168.68.2";
    forwardPorts = [
      {
        hostPort = config.containers.chrome-rdp.config.services.xrdp.port;
        containerPort = config.containers.chrome-rdp.config.services.xrdp.port;
        protocol = "tcp";
      }
    ];
    bindMounts = {
      chrome-profile = {
        mountPoint = "/home";
        hostPath = "/var/lib/chromerdp-container";
        isReadOnly = false;
      };
    };
    config =
      { pkgs, ... }:
      {
        services.xserver = {
          enable = true;
          desktopManager = {
            xterm.enable = false;
            # mate.enable = true;
            xfce.enable = true;
          };
          displayManager.lightdm.enable = false;
        };
        hardware.pulseaudio = {
          enable = true;
          extraModules = [ super-pkgs.pulseaudio-module-xrdp ];
        };
        environment.systemPackages = with pkgs; [
          chromium
          firefox
          super-pkgs.pulseaudio-module-xrdp
        ];
        environment.etc."xrdp/sesman.ini".source = "${rdpConfDir}/sesman.ini";
        services.xrdp = {
          enable = true;
          package = pkgs.xrdp.overrideAttrs (old: {
            configureFlags = old.configureFlags ++ [
              "--enable-mp3lame"
              "--enable-vsock"
              "--enable-pixman"
              "--enable-rdpsndaudin"
              "--enable-tjpeg"
              "--enable-devel-logging"
            ];
            buildInputs = old.buildInputs ++ [
              pkgs.lame
              pkgs.pixman
              pkgs.libjpeg_turbo
            ];
            postPatch = ''
              ${old.postPatch}
              substituteInPlace configure.ac --replace /usr/include/ ""
            '';
          });
          confDir = rdpConfDir;
          openFirewall = true;
          defaultWindowManager = ''xfce4-session'';
        };
        users.users.test = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "video"
            "render"
            "audio"
          ];
          initialPassword = "test";
          uid = 6969;
        };

        system.stateVersion = "23.11";
      };
  };
}
