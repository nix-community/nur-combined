{
  drv,
  pkgs,
}:
pkgs.dockerTools.buildLayeredImage {
  name = drv.pname;
  tag = drv.version;

  contents = with pkgs; [
    dockerTools.caCertificates
  ];

  created = "now";
  meta = drv.meta;

  config = {
    Cmd = [ "${pkgs.lib.meta.getExe drv}" ];
    Labels = pkgs.lib.filterAttrs (_: v: v != null) {
      "org.opencontainers.image.title" = if drv ? pname then drv.pname else null;

      "org.opencontainers.image.description" =
        if drv ? meta && drv.meta ? description then drv.meta.description else null;

      "org.opencontainers.image.version" = if drv ? version then drv.version else null;

      "org.opencontainers.image.source" =
        if drv ? meta && drv.meta ? homepage then drv.meta.homepage else null;

      "org.opencontainers.image.licenses" =
        if drv ? meta && drv.meta ? license && drv.meta.license ? spdxId then
          drv.meta.license.spdxId
        else
          null;
    };
  };
}
