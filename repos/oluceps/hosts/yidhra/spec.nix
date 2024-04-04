{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  # server.

  system.stateVersion = "22.11";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
    inherit ((import ../sysctl.nix { inherit lib; }).boot) kernel;
  };

  services =
    (
      let
        importService = n: import ../../services/${n}.nix { inherit pkgs config inputs; };
      in
      lib.genAttrs [
        "openssh"
        "fail2ban"
      ] (n: importService n)
    )
    // {

      juicity.instances = [
        {
          name = "only";
          credentials = [
            "key:${config.age.secrets."nyaw.key".path}"
            "cert:${config.age.secrets."nyaw.cert".path}"
          ];
          serve = true;
          openFirewall = 23180;
          configFile = config.age.secrets.juic-san.path;
        }
      ];
      rustypaste = {
        enable = true;
        settings = {
          config = {
            refresh_rate = "3s";
          };
          landing_page = {
            content_type = "text/plain; charset=utf-8";
            text = ''
              ┬─┐┬ ┬┌─┐┌┬┐┬ ┬┌─┐┌─┐┌─┐┌┬┐┌─┐
              ├┬┘│ │└─┐ │ └┬┘├─┘├─┤└─┐ │ ├┤
              ┴└─└─┘└─┘ ┴  ┴ ┴  ┴ ┴└─┘ ┴ └─┘
              Submit files via HTTP POST here:
                  curl -F 'file=@example.txt' <server>
              This will return the URL of the uploaded file nya.
              The server administrator might remove any pastes that they do not personally
              want to host.
              If you are the server administrator and want to change this page, just go
              into your config file and change it! If you change the expiry time, it is
              recommended that you do.
              By default, pastes expire every hour. The server admin may or may not have
              changed this.
              Check out the GitHub repository at https://github.com/orhun/rustypaste
              Command line tool is available  at https://github.com/orhun/rustypaste-cli
            '';
          };
          paste = {
            default_expiry = "64h";
            default_extension = "txt";
            delete_expired_files = {
              enabled = true;
              interval = "1h";
            };
            duplicate_files = true;
            mime_blacklist = [
              "application/x-dosexec"
              "application/java-archive"
              "application/java-vm"
            ];
            mime_override = [
              {
                mime = "image/jpeg";
                regex = "^.*\\.jpg$";
              }
              {
                mime = "image/png";
                regex = "^.*\\.png$";
              }
              {
                mime = "image/svg+xml";
                regex = "^.*\\.svg$";
              }
              {
                mime = "video/webm";
                regex = "^.*\\.webm$";
              }
              {
                mime = "video/x-matroska";
                regex = "^.*\\.mkv$";
              }
              {
                mime = "application/octet-stream";
                regex = "^.*\\.bin$";
              }
              {
                mime = "text/plain";
                regex = "^.*\\.(log|txt|diff|sh|rs|toml)$";
              }
            ];
            random_url = {
              separator = "-";
              type = "petname";
              words = 2;
            };
          };
          server = {
            address = "127.0.0.1:3999";
            expose_list = false;
            expose_version = false;
            handle_spaces = "replace";
            max_content_length = "10MB";
            timeout = "30s";
            upload_path = "./upload";
            url = "https://pb.nyaw.xyz";
          };
        };
      };

      caddy = {
        enable = true;
        # user = "root";
        # configFile = config.age.secrets.caddy-lsa.path;
        # package = pkgs.caddy-mod;
        # globalConfig = ''
        #   	order forward_proxy before file_server
        # '';
        virtualHosts = {
          "magicb.uk" = {
            hostName = "magicb.uk";
            extraConfig = ''
              tls mn1.674927211@gmail.com
              file_server {
                  root /var/www/public
              }
            '';
          };

          "pb.nyaw.xyz" = {
            hostName = "pb.nyaw.xyz";
            extraConfig = ''
              reverse_proxy 127.0.0.1:3999
              tls ${config.age.secrets."nyaw.cert".path} ${config.age.secrets."nyaw.key".path}
            '';
          };

          "nyaw.xyz" = {
            hostName = "nyaw.xyz";
            extraConfig = ''
              reverse_proxy 10.0.1.2:3000
              tls ${config.age.secrets."nyaw.cert".path} ${config.age.secrets."nyaw.key".path}
              redir /matrix https://matrix.to/#/@sec:nyaw.xyz

              header /.well-known/matrix/* Content-Type application/json
              header /.well-known/matrix/* Access-Control-Allow-Origin *
              respond /.well-known/matrix/server `{"m.server": "matrix.nyaw.xyz:443"}`
              respond /.well-known/matrix/client `{"m.homeserver": {"base_url": "https://matrix.nyaw.xyz"},"org.matrix.msc3575.proxy": {"url": "https://matrix.nyaw.xyz"}}`
            '';
          };
          "matrix.nyaw.xyz" = {
            hostName = "matrix.nyaw.xyz";
            extraConfig = ''
              reverse_proxy /_matrix/* 10.0.1.2:6167
            '';
          };
          "ctos.magicb.uk" = {
            hostName = "ctos.magicb.uk";
            extraConfig = ''
              tls mn1.674927211@gmail.com
              reverse_proxy 10.0.1.2:10002
            '';
          };
        };
      };
    };

  programs = {
    git.enable = true;
    fish.enable = true;
  };
  zramSwap = {
    enable = true;
    swapDevices = 1;
    memoryPercent = 80;
    algorithm = "zstd";
  };

  systemd = {
    enableEmergencyMode = false;
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 10s.
      # If the hardware watchdog does not get a signal for 20s,
      # it will forcefully reboot the system.
      runtimeTime = "20s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
    };
  };

  systemd.tmpfiles.rules = [ ];
}
