# OLS: Offline Location Service: <https://codeberg.org/tpikonen/ols>
# fields {wifi SSID,cell tower} -> lat/long queries from geoclue
# satisfies queries via https://wigle.net, by learning about map tiles
# and caching those on-disk so that repeat queries may be serviced offline.
#
# it listens on localhost:8088, and one can validate its operation with a query like (substitute macAddresses for something real):
# - WiFi:  curl -d '{"wifiAccessPoints":[{"macAddress":"01:23:45:67:89:ab","signalStrength":-78},{"macAddress":"cd:ef:01:23:45:56","signalStrength":-76}]}' http://127.0.0.1:8088/v1/geolocate
# - Cell:  curl -d '{"cellTowers":[{ "radioType": "lte", "mobileCountryCode": 310, "mobileNetworkCode": 260, "locationAreaCode": NNNNN, "cellId": MMMMMMMM }]}' http://127.0.0.1:8088/v1/geolocate
#
## wigle docs:
# - IRC: #wigle on WiGLE.net:6667
# - API: <https://api.wigle.net/swagger>
#   API return codes:
#   - 429: "too many queries today."
#
# rate limiting:
# - as a new user you'll be limited to something ridiculous like 5 queries per day.
#   supposedly this improves "based on history and participation".
#   - source: <https://api.wigle.net/swagger#/Network%20search%20and%20information%20tools/search_2>
# - "API for some functions is limited on a daily basis for all users for the time being, but if you'd like increased access, please email us (include your username and usecase) at WiGLE-admin@wigle.net."
#   - source: <https://wigle.net/account>
{ pkgs, ... }:
{
  sane.programs.ols = {
    packageUnwrapped = pkgs.geoclue-ols;

    fs.".config/ols/cell.db".symlink.target = pkgs.runCommandLocal "cell.db" {
      nativeBuildInputs = [ pkgs.geoclue-ols ];
    } ''
      cellid-ols-import -o "$out" "${pkgs.opencellid}"
    '';

    persist.byStore.private = [
      ".local/share/ols"
    ];

    secrets.".config/ols/ols.toml" = ../../../secrets/common/ols.toml.bin;

    sandbox.method = "bwrap";
    sandbox.net = "all";

    services.ols = {
      description = "ols: Offline Location Service";
      command = "ols 2>&1";  # XXX: it logs to stderr, and my s6 infrastructure apparently doesn't handle that
      partOf = [ "graphical-session" ];
    };
  };
}
