# docs:
# - <repo:LemmyNet/lemmy:docker/federation/nginx.conf>
# - <repo:LemmyNet/lemmy:docker/nginx.conf>
# - <repo:LemmyNet/lemmy-ansible:templates/nginx.conf>

{ config, lib, ... }:
let
  inherit (builtins) toString;
  inherit (lib) mkForce;
  uiPort = 1234;  # default ui port is 1234
  backendPort = 8536; # default backend port is 8536
  # - i guess the "backend" port is used for federation?
in {
  services.lemmy = {
    enable = true;
    settings.hostname = "lemmy.uninsane.org";
    # federation.debug forces outbound federation queries to be run synchronously
    # N.B.: this option might not be read for 0.17.0+? <https://github.com/LemmyNet/lemmy/blob/c32585b03429f0f76d1e4ff738786321a0a9df98/RELEASES.md#upgrade-instructions>
    # settings.federation.debug = true;
    settings.port = backendPort;
    ui.port = uiPort;
    database.createLocally = true;
    nginx.enable = true;
  };

  systemd.services.lemmy.serviceConfig = {
    # fix to use a normal user so we can configure perms correctly
    DynamicUser = mkForce false;
    User = "lemmy";
    Group = "lemmy";
  };
  systemd.services.lemmy.environment = {
    RUST_BACKTRACE = "full";
    # RUST_LOG = "debug";
    # RUST_LOG = "trace";
    # upstream defaults LEMMY_DATABASE_URL = "postgres:///lemmy?host=/run/postgresql";
    # - Postgres complains that we didn't specify a user
    # lemmy formats the url as:
    # - postgres://{user}:{password}@{host}:{port}/{database}
    # SO suggests (https://stackoverflow.com/questions/3582552/what-is-the-format-for-the-postgresql-connection-string-url):
    # - postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]
    # LEMMY_DATABASE_URL = "postgres://lemmy@/run/postgresql";  # connection to server on socket "/run/postgresql/.s.PGSQL.5432" failed: FATAL:  database "run/postgresql" does not exist
    # LEMMY_DATABASE_URL = "postgres://lemmy?host=/run/postgresql";  # no PostgreSQL user name specified in startup packet
    # LEMMY_DATABASE_URL = mkForce "postgres://lemmy@?host=/run/postgresql";  # WORKS
    LEMMY_DATABASE_URL = mkForce "postgres://lemmy@/lemmy?host=/run/postgresql";
  };
  users.groups.lemmy = {};
  users.users.lemmy = {
    group = "lemmy";
    isSystemUser = true;
  };

  services.nginx.virtualHosts."lemmy.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
  };

  sane.dns.zones."uninsane.org".inet.CNAME."lemmy" = "native";
}
