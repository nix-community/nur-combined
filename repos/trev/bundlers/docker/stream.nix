{
  drv,
  pkgs,
}:
pkgs.dockerTools.streamLayeredImage {
  name = drv.pname;
  tag = drv.version;
  architecture = drv.stdenv.hostPlatform.go.GOARCH or "amd64";
  meta = drv.meta or { };

  contents = with pkgs; [
    dockerTools.caCertificates
  ];

  config = {
    Cmd = [ "${pkgs.lib.meta.getExe drv}" ];
    Labels = pkgs.lib.filterAttrs (_: v: v != null) {
      "org.opencontainers.image.title" = drv.pname or null;
      "org.opencontainers.image.description" = drv.meta.description or null;
      "org.opencontainers.image.version" = drv.version or null;
      "org.opencontainers.image.source" = drv.meta.homepage or null;
      "org.opencontainers.image.licenses" = drv.meta.license.spdxId or null;
    };
  };
}
