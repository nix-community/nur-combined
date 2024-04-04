{
  pkgs,
  config,
  inputs,
  ...
}:
{
  enable = true;
  disableTxChecksumIpGeneric = false;
  configFile = config.age.secrets.dae.path;
  # package = pkgs.dae-unstable;
  assetsPath = toString (
    pkgs.symlinkJoin {
      name = "dae-assets-nixy";
      paths = [
        "${inputs.nixyDomains}/assets"
        "${pkgs.v2ray-geoip}/share/v2ray"
      ];
    }
  );

  openFirewall = {
    enable = true;
    port = 12345;
  };
}
