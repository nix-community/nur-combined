# docs: <https://nixos.wiki/wiki/Matrix>
# docs: <https://nixos.org/manual/nixos/stable/index.html#module-services-matrix-synapse>
# example config: <https://github.com/matrix-org/synapse/blob/develop/docs/sample_config.yaml>
{ config, lib, pkgs, ... }:

{
  imports = [
    ./discord-puppet.nix
    ./irc.nix
    ./signal.nix
  ];

  sane.persist.sys.plaintext = [
    { user = "matrix-synapse"; group = "matrix-synapse"; directory = "/var/lib/matrix-synapse"; }
  ];
  services.matrix-synapse.enable = true;
  # this changes the default log level from INFO to WARN.
  # maybe there's an easier way?
  services.matrix-synapse.settings.log_config = ./synapse-log_level.yaml;
  services.matrix-synapse.settings.server_name = "uninsane.org";

  # services.matrix-synapse.enable_registration_captcha = true;
  # services.matrix-synapse.enable_registration_without_verification = true;
  services.matrix-synapse.settings.enable_registration = true;
  # services.matrix-synapse.registration_shared_secret = "<shared key goes here>";

  # default for listeners is port = 8448, tls = true, x_forwarded = false.
  # we change this because the server is situated behind nginx.
  services.matrix-synapse.settings.listeners = [
    {
      port = 8008;
      bind_addresses = [ "127.0.0.1" ];
      type = "http";
      tls = false;
      x_forwarded = true;
      resources = [
        {
          names = [ "client" "federation" ];
          compress = false;
        }
      ];
    }
  ];

  services.matrix-synapse.settings.x_forwarded = true;  # because we proxy matrix behind nginx
  services.matrix-synapse.settings.max_upload_size = "100M";  # default is "50M"

  services.matrix-synapse.settings.admin_contact = "admin.matrix@uninsane.org";
  services.matrix-synapse.settings.registrations_require_3pid = [ "email" ];

  services.matrix-synapse.extraConfigFiles = [
    config.sops.secrets.matrix_synapse_secrets.path
  ];

  # services.matrix-synapse.extraConfigFiles = [builtins.toFile "matrix-synapse-extra-config" ''
  #   admin_contact: "admin.matrix@uninsane.org"
  #   registrations_require_3pid:
  #     - email
  #   email:
  #     smtp_host: "mx.uninsane.org"
  #     smtp_port: 587
  #     smtp_user: "matrix-synapse"
  #     smtp_pass: "${secrets.matrix-synapse.smtp_pass}"
  #     require_transport_security: true
  #     enable_tls: true
  #     notif_from: "%(app)s <notify.matrix@uninsane.org>"
  #     app_name: "Uninsane Matrix"
  #     enable_notifs: true
  #     validation_token_lifetime: 96h
  #     invite_client_location: "https://web.matrix.uninsane.org"
  #     subjects:
  #       email_validation: "[%(server_name)s] Validate your email"
  # ''];

  # new users may be registered on the CLI:
  #   register_new_matrix_user -c /nix/store/8n6kcka37jhmi4qpd2r03aj71pkyh21s-homeserver.yaml http://localhost:8008
  #
  # or provide an registration token then can use to register through the client.
  #   docs: https://github.com/matrix-org/synapse/blob/develop/docs/usage/administration/admin_api/registration_tokens.md
  # first, grab your own user's access token (Help & About section in Element). then:
  #   curl --header "Authorization: Bearer <my_token>" localhost:8008/_synapse/admin/v1/registration_tokens
  # create a token with unlimited uses:
  #   curl -d '{}' --header "Authorization: Bearer <my_token>" localhost:8008/_synapse/admin/v1/registration_tokens/new
  # create a token with limited uses:
  #   curl -d '{ "uses_allowed": 1 }' --header "Authorization: Bearer <my_token>" localhost:8008/_synapse/admin/v1/registration_tokens/new

  # matrix chat server
  # TODO: was `publog`
  services.nginx.virtualHosts."matrix.uninsane.org" = {
    addSSL = true;
    enableACME = true;
    # inherit kTLS;

    # TODO colin: replace this with something helpful to the viewer
    # locations."/".extraConfig = ''
    #   return 404;
    # '';

    locations."/" = {
      proxyPass = "http://127.0.0.1:8008";
      extraConfig = ''
        # allow uploading large files (matrix enforces a separate limit, downstream)
        client_max_body_size  512m;
      '';
    };
    # redirect browsers to the web client.
    # i don't think native matrix clients ever fetch the root.
    # ideally this would be put behind some user-agent test though.
    locations."= /" = {
      return = "301 https://web.matrix.uninsane.org";
    };

    # locations."/_matrix" = {
    #   proxyPass = "http://127.0.0.1:8008";
    # };
  };

  # matrix web client
  # docs: https://nixos.org/manual/nixos/stable/index.html#module-services-matrix-element-web
  services.nginx.virtualHosts."web.matrix.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    # inherit kTLS;

    root = pkgs.element-web.override {
      conf = {
        default_server_config."m.homeserver" = {
          "base_url" = "https://matrix.uninsane.org";
          "server_name" = "uninsane.org";
        };
      };
    };
  };

  sane.services.trust-dns.zones."uninsane.org".inet = {
    CNAME."matrix" = "native";
    CNAME."web.matrix" = "native";
  };


  sops.secrets."matrix_synapse_secrets" = {
    owner = config.users.users.matrix-synapse.name;
  };
}
