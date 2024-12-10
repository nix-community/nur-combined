# OLS: Offline Location Service: <https://codeberg.org/tpikonen/ols>
# fields {wifi SSID,cell tower} -> lat/long queries from geoclue
# satisfies queries via an on-device cell database (see `pkgs.opencellid`)
#
# it listens on localhost:8088, and one can validate its operation with a query like (substitute macAddresses for something real):
# - WiFi:  curl -d '{"wifiAccessPoints":[{"macAddress":"01:23:45:67:89:ab","signalStrength":-78},{"macAddress":"cd:ef:01:23:45:56","signalStrength":-76}]}' http://127.0.0.1:8088/v1/geolocate
# - Cell:  curl -d '{"cellTowers":[{ "radioType": "lte", "mobileCountryCode": 310, "mobileNetworkCode": 260, "locationAreaCode": NNNNN, "cellId": MMMMMMMM }]}' http://127.0.0.1:8088/v1/geolocate
#   - get parameters from `mmcli -m any --location-enable-3gpp` + `mmcli -m any --location-get`
#     use `tracking area code` and `cell id` (both in hex)
#
# it USED to use WiGLE, but they're pretty determined to make their service unusable.
# - IRC: #wigle on WiGLE.net:6667
{ pkgs, ... }:
{
  sane.programs.ols = {
    packageUnwrapped = pkgs.geoclue-ols;

    fs.".config/ols/cell.db".symlink.target = pkgs.runCommand "cell.db" {
      preferLocalBuild = true;
      nativeBuildInputs = [ pkgs.geoclue-ols ];
    } ''
      cellid-ols-import -o "$out" "${pkgs.opencellid}"
    '';

    persist.byStore.private = [
      ".local/share/ols"
    ];

    secrets.".config/ols/ols.toml" = ../../../secrets/common/ols.toml.bin;

    sandbox.net = "localhost";

    services.ols = {
      description = "ols: Offline Location Service";
      command = "ols";
      # command = "ols 2>&1";  # XXX: it logs to stderr, and my s6 infrastructure apparently doesn't handle that
      partOf = [ "graphical-session" ];
    };
  };
}
