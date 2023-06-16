{ config, pkgs, lib, materusFlake, ... }:
let

  socketPath = "/run/pleroma/http.sock";


  socketChmod = with pkgs; with lib; pkgs.writers.writeBashBin "pleroma-socket"
    ''
      coproc {
          ${inotify-tools}/bin/inotifywait -q -m -e create ${escapeShellArg (dirOf socketPath)}
        }

        trap 'kill "$COPROC_PID"' EXIT TERM

        until ${pkgs.coreutils}/bin/test -S ${escapeShellArg socketPath}
          do read -r -u "''${COPROC[0]}"
        done

      ${pkgs.coreutils}/bin/chmod 0666 ${socketPath}
    '';

  soapbox = pkgs.stdenv.mkDerivation rec {
    pname = "soapbox";
    version = "v3.2.0";
    dontBuild = true;
    dontConfigure = true;
    src = pkgs.fetchurl {
      name = "soapbox";
      url = "https://gitlab.com/soapbox-pub/soapbox/-/jobs/artifacts/${version}/download?job=build-production";
      sha256 = "sha256-AdW6JK7JkIKLZ8X+N9STeOHqmGNUdhcXyC9jsQPTa9o=";
    };
    nativeBuildInputs = [pkgs.unzip];
    unpackPhase = ''
    unzip $src -d .
    '';
    installPhase = ''
    mv ./static $out
    '';

  };

in
{
  systemd.tmpfiles.rules = [
    "d    /var/lib/pleroma   0766    pleroma    pleroma     -"
    "d    /var/lib/pleroma/static   0766    pleroma    pleroma     -"
    "d    /var/lib/pleroma/uploads   0766    pleroma    pleroma     -"
    "L+   /var/lib/pleroma/static/frontends/soapbox/${soapbox.version}  0766 pleroma pleroma - ${soapbox}"
  ];

  services.nginx.virtualHosts."podkos.xyz" = {
    http2 = true;
    useACMEHost = "podkos.xyz";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://unix:${socketPath}";
      extraConfig = ''
        etag on;
        gzip on;

        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'POST, PUT, DELETE, GET, PATCH, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Idempotency-Key' always;
        add_header 'Access-Control-Expose-Headers' 'Link, X-RateLimit-Reset, X-RateLimit-Limit, X-RateLimit-Remaining, X-Request-Id' always;
        if ($request_method = OPTIONS) {
          return 204;
        }

        add_header X-XSS-Protection "1; mode=block";
        add_header X-Permitted-Cross-Domain-Policies none;
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header Referrer-Policy same-origin;
        add_header X-Download-Options noopen;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;

        client_max_body_size 8m;
      
      
      '';
    };

  };
  systemd.services.pleroma.serviceConfig = {
    RuntimeDirectory = "pleroma";
    RuntimeDirectoryPreserve = true;


    ExecStartPost = "${socketChmod}/bin/pleroma-socket";
    ExecStopPost = ''${pkgs.coreutils}/bin/rm -f ${socketPath}'';
  };




  services.pleroma = {
    enable = true;
    secretConfigFile = "/var/lib/pleroma/secrets.exs";
    configs = [
      ''
        import Config

        config :pleroma, Pleroma.Web.Endpoint,
          url: [host: "podkos.xyz", scheme: "https", port: 443],
          http: [ip: {:local, "${socketPath}"}, port: 0]

        config :pleroma, :instance,
          name: "Podziemia Kosmosu",
          email: "admin@podkos.xyz",
          notify_email: "noreply@podkos.xyz",
          limit: 5000,
          registrations_open: false

        config :pleroma, :media_proxy,
          enabled: false,
          redirect_on_failure: true

        config :pleroma, Pleroma.Repo,
          adapter: Ecto.Adapters.Postgres,
          socket: "/run/postgresql/.s.PGSQL.5432",
          username: "pleroma",
          database: "pleroma"
          

        # Configure web push notifications
        config :web_push_encryption, :vapid_details,
          subject: "mailto:admin@podkos.x yz"
        config :pleroma, :frontends,
          primary: %{
            "name" => "soapbox",
            "ref" => "${soapbox.version}"
          }

        config :pleroma, :database, rum_enabled: false
        config :pleroma, :instance, static_dir: "/var/lib/pleroma/static"
        config :pleroma, Pleroma.Uploaders.Local, uploads: "/var/lib/pleroma/uploads"

        config :pleroma, configurable_from_database: true  
        config :pleroma, Pleroma.Upload, filters: [Pleroma.Upload.Filter.AnonymizeFilename]
      ''
    ];
  };
}
