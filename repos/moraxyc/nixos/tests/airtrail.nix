{
  lib,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "airtrail";

  containers.machine = _: {
    imports = [ ../modules/services/web-apps/airtrail.nix ];

    services.airtrail = {
      enable = true;
      package = pkgs.airtrail;
    };

    # AirTrail downloads its initial airport and reference data at startup.
    # Seed the minimum database state needed by the service test so it does
    # not depend on external network access.
    systemd.services.airtrail.serviceConfig.ExecStartPre = lib.mkAfter [
      (pkgs.writeShellScript "airtrail-test-seed" ''
        set -eu

        ${lib.getExe' pkgs.postgresql "psql"} \
          "postgresql://airtrail@localhost/airtrail?host=/run/postgresql" <<'SQL'
        INSERT INTO airport (icao, iata, lat, lon, tz, name, municipality, type, continent, country, custom)
        VALUES ('TEST', 'TST', 0, 0, 'UTC', 'Test Airport', 'Test', 'small_airport', 'NA', 'US', false);

        UPDATE app_config
        SET config = jsonb_set(
          config,
          '{data,lastSynced}',
          '"2026-01-01T00:00:00.000Z"',
          true
        );
        SQL
      '')
    ];
  };

  testScript = ''
    machine.wait_for_unit("airtrail.service")
    machine.wait_for_open_port(3000)
    machine.succeed("curl --fail http://127.0.0.1:3000/api/ping")
  '';

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
