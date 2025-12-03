# docs: <https://nixos.wiki/wiki/Matrix>
# docs: <https://nixos.org/manual/nixos/stable/index.html#module-services-matrix-synapse>
# example config: <https://github.com/element-hq/synapse/blob/develop/docs/sample_config.yaml>
#
# ENABLING PUSH NOTIFICATIONS (with UnifiedPush/ntfy):
# - Matrix "pushers" API spec: <https://spec.matrix.org/latest/client-server-api/#post_matrixclientv3pushersset>
# - first, view notification settings:
#   - obtain your client's auth token. e.g. Element -> profile -> help/about -> access token.
#   - `curl --header 'Authorization: Bearer <your_access_token>' localhost:8008/_matrix/client/v3/pushers | jq .`
# - enable a new notification destination:
#   - `curl --header "Authorization: Bearer <your_access_token>" --data '{ "app_display_name": "<topic>", "app_id": "ntfy.uninsane.org", "data": { "url": "https://ntfy.uninsane.org/_matrix/push/v1/notify", "format": "event_id_only" }, "device_display_name": "<topic>", "kind": "http", "lang": "en-US", "profile_tag": "", "pushkey": "<topic>" }' localhost:8008/_matrix/client/v3/pushers/set`
# - delete a notification destination by setting `kind` to `null` (otherwise, request is identical to above)
#
{ config, lib, pkgs, ... }:
let
  ntfy = config.services.ntfy-sh.enable;
in
{
  imports = [
    ./discord-puppet.nix
    ./irc.nix
    ./signal.nix
  ];

  sane.persist.sys.byStore.private = [
    { user = "matrix-synapse"; group = "matrix-synapse"; path = "/var/lib/matrix-synapse"; method = "bind"; }
  ];
  services.matrix-synapse.enable = true;
  services.matrix-synapse.log.root.level = "ERROR";  # accepts "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL" (?)
  services.matrix-synapse.settings = {
    server_name = "uninsane.org";

    # services.matrix-synapse.enable_registration_captcha = true;
    # services.matrix-synapse.enable_registration_without_verification = true;
    # enable_registration = true;
    # services.matrix-synapse.registration_shared_secret = "<shared key goes here>";

    # default for listeners is port = 8448, tls = true, x_forwarded = false.
    # we change this because the server is situated behind nginx.
    listeners = [
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

    ip_range_whitelist = [
      # to communicate with ntfy.uninsane.org push notifs.
      # TODO: move this to some non-shared loopback device: we don't want Matrix spouting http requests to *anything* on this machine
      "10.78.79.51"
    ];

    x_forwarded = true;  # because we proxy matrix behind nginx
    max_upload_size = "100M";  # default is "50M"

    admin_contact = "admin.matrix@uninsane.org";
    registrations_require_3pid = [ "email" ];
  };

  services.matrix-synapse.extraConfigFiles = [
    config.sops.secrets."matrix_synapse_secrets.yaml".path
  ];

  # tune restart settings to ensure systemd doesn't disable it, and we don't overwhelm postgres
  systemd.services.matrix-synapse.serviceConfig.RestartSec = 5;
  systemd.services.matrix-synapse.serviceConfig.RestartMaxDelaySec = 20;
  systemd.services.matrix-synapse.serviceConfig.StartLimitBurst = 120;
  systemd.services.matrix-synapse.serviceConfig.RestartSteps = 3;
  # switch postgres from Requires -> Wants, so that postgres may restart without taking matrix down with it.
  systemd.services.matrix-synapse.requires = lib.mkForce [];
  systemd.services.matrix-synapse.wants = [ "postgresql.service" ];

  systemd.services.matrix-synapse.postStart = lib.optionalString ntfy ''
    ACCESS_TOKEN=$(${lib.getExe' pkgs.coreutils "cat"} ${config.sops.secrets.matrix_access_token.path})
    TOPIC=$(${lib.getExe' pkgs.coreutils "cat"} ${config.sops.secrets.ntfy-sh-topic.path})

    echo "ensuring ntfy push gateway"
    ${lib.getExe pkgs.curl} \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      --data "{ \"app_display_name\": \"ntfy-adapter\", \"app_id\": \"ntfy.uninsane.org\", \"data\": { \"url\": \"https://ntfy.uninsane.org/_matrix/push/v1/notify\", \"format\": \"event_id_only\" }, \"device_display_name\": \"ntfy-adapter\", \"kind\": \"http\", \"lang\": \"en-US\", \"profile_tag\": \"\", \"pushkey\": \"$TOPIC\" }" \
      localhost:8008/_matrix/client/v3/pushers/set

    echo "registered push gateways:"
    ${lib.getExe pkgs.curl} \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      localhost:8008/_matrix/client/v3/pushers \
      | ${lib.getExe pkgs.jq} .
  '';


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
      recommendedProxySettings = true;
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

  sane.dns.zones."uninsane.org".inet = {
    CNAME."matrix" = "native";
    CNAME."web.matrix" = "native";
  };


  sops.secrets."matrix_synapse_secrets.yaml" = {
    owner = config.users.users.matrix-synapse.name;
  };
  sops.secrets."matrix_access_token" = {
    owner = config.users.users.matrix-synapse.name;
  };
  # provide access to ntfy-sh-topic secret
  users.users.matrix-synapse.extraGroups = lib.optionals ntfy [ "ntfy-sh" ];
}
