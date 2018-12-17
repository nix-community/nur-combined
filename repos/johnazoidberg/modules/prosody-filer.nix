{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.prosody-filer;
in
{
  ##### interface
  options = {
    services.prosody-filer = {
      enable = mkEnableOption "prosody-filer";

      description = ''
        Golang mod_http_upload_external server for Prosody
      '';

      externalDomain = mkOption {
        type = types.str;
        description = "External domain which clients use to upload/download media";
        example = "jabber.example.com";
      };

      listenAddress = mkOption {
        type = types.str;
        description = "IP address and port to listen on";
        default = "127.0.0.1:5050";
      };

      secret = mkOption {
        type = types.str;
        description = "Secret for calculating the HMAC. Same as on the server.";
      };

      dataDir = mkOption {
        type = types.string;
        description = "Directory where to store the uploaded files";
        default = "/var/lib/prosody-filer";
      };

      uploadDir = mkOption {
        type = types.string;
        description = "Subdirectory for HTTP upload / download requests";
        default = "upload/";
      };

      user = mkOption {
        type = types.str;
        default = "prosody-filer";
        description = "User account under which prosody-filer runs";
      };

      group = mkOption {
        type = types.str;
        default = "prosody-filer";
        description = "Group account under which prosody-filer runs";
      };

      vHost = mkOption {
        description = "Configuration for external facing webserver";

        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              description = ''
                Set up an nginx server to serve uploads and downloads.
                If you disable this you have to proxy it yourself to the prosody-filer listening on localhost.
              '';
            };

            sslCertificate = mkOption {
              type = types.nullOr types.path;
              description = "Path to the TLS/SSl certificate of external domain";
              default = null;
            };

            sslCertificateKey = mkOption {
              type = types.nullOr types.path;
              description = "Path to the certificate private key of externalDomain";
              default = null;
            };
          };
        };
      };
    };
  };


  ##### implementation
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.vHost.enable || (cfg.vHost.enable
                                          && cfg.vHost.sslCertificate != null
                                          && cfg.vHost.sslCertificateKey != null);
	message = "If you enable vHost you have to set SSL key and certificate";
      }
    ];

    services.nginx = mkIf cfg.vHost.enable {
      enable = true;
      virtualHosts = {
        "${cfg.externalDomain}" = {
          listen = [{
            addr = "127.0.0.1";
            port = 443;
            ssl = true;
          }];

          onlySSL = true;
          sslCertificate = cfg.vHost.sslCertificate;
          sslCertificateKey = cfg.vHost.sslCertificateKey;

          locations = {
            "/upload/" = {
              proxyPass = "http://127.0.0.1:5050/upload/";
              extraConfig = ''
                proxy_request_buffering off;
              '';
            };
          };
        };
      };
    };

    environment.etc."prosody-filer.toml".text = ''
      listenport      = "${cfg.listenAddress}"
      secret          = "${cfg.secret}"
      storeDir        = "${cfg.dataDir}/"
      uploadSubDir    = "${cfg.uploadDir}"
    '';

    services.prosody = {
      extraConfig = ''
        http_upload_external_base_url = "https://${cfg.externalDomain}/${cfg.uploadDir}"
        http_upload_external_secret = "${cfg.secret}"
        http_upload_external_file_size_limit = 50000000 -- 50 MB
      '';

      # TODO Does can we merge this with the already present modules?
      package = pkgs.prosody.override {
        withCommunityModules = [ "http_upload_external" ];
      };
    };


    users.users.prosody-filer = mkIf (cfg.user == "prosody-filer") {
      # FIXME why doesn't this work with uid?
      #uid = config.ids.uids.prosody-filer;
      description = "Prosody-filer user";
      createHome = true;
      inherit (cfg) group;
      home = "${cfg.dataDir}";
    };

    users.groups.prosody-filer = mkIf (cfg.group == "prosody-filer") {
      # FIXME why doesn't this work with gid?
      #gid = config.ids.gids.prosody-filer;
    };

    systemd.services.prosody-filer = {
      description = "Prosody file upload server";

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      restartTriggers = [ config.environment.etc."prosody-filer.toml".source ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        RuntimeDirectory = [ "prosody-filer" ];
	Restart = "always";
	WorkingDirectory = "${cfg.dataDir}";
        ExecStart = "${pkgs.prosody-filer}/bin/prosody-filer -config /etc/prosody-filer.toml";
      };
    };
  };
}
