{
  config,
  pkgs,
  lib,
  vaculib,
  ...
}:
let
  inherit (pkgs) most-winningest;
in
{
  users.users.jl-stats = {
    isSystemUser = true;
    home = "/var/lib/jl-stats";
    group = "jl-stats";
  };
  users.groups.jl-stats = { };
  users.groups.jl-stats-generated.members = [
    "caddy"
    "jl-stats"
  ];
  systemd.tmpfiles.settings.whatever."/var/lib/jl-stats-generated".d = {
    user = "jl-stats";
    group = "jl-stats-generated";
    mode = vaculib.accessModeStr {
      user = "all";
      group = {
        read = true;
        execute = true;
      };
    };
  };
  services.postgresql.ensureUsers = [
    {
      name = "jl-stats";
      ensureDBOwnership = true;
    }
  ];
  services.postgresql.ensureDatabases = [ "jl-stats" ];
  systemd.services.jl-stats-update = {
    confinement = {
      enable = true;
      # packages = [ most-winningest most-winningest.src ];
    };
    environment = {
      DATABASE_URL = "postgres://jl-stats@/jl-stats";
    };
    script = ''
      # temp_src="$(mktemp -d)"
      # copy to a writable dir because diesel-cli insists on e
      # cp -r ${most-winningest.src} "$temp_src"
      # cd "$temp_src"
      cd ${most-winningest.src}
      ${
        pkgs.diesel-cli.override {
          sqliteSupport = false;
          mysqlSupport = false;
        }
      }/bin/diesel migration run --config-file /dev/null

      cd /var/lib/jl-stats-generated
      ${lib.getExe most-winningest}
    '';
    serviceConfig = {
      User = "jl-stats";
      Group = "jl-stats";
      StateDirectory = "jl-stats";
      StateDirectoryMode = vaculib.accessModeStr { user = "all"; };
      BindPaths = [
        "/var/lib/jl-stats-generated"
        "/run/postgresql"
      ];
      BindReadOnlyPaths = [
        "/etc/resolv.conf"
        "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
      ];
    };
  };
  systemd.timers.jl-stats-update = {
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnActiveSec = "1m";
      OnUnitInactiveSec = "1h";
      RandomizedDelaySec = "5m";
      DeferReactivation = true;
    };
  };

  services.caddy.virtualHosts."stats.jean-luc.org" = {
    vacu.hsts = "preload";
    extraConfig = ''
      root * /var/lib/jl-stats-generated/generated
      file_server
    '';
  };
}
