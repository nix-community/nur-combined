{
  drv,
  pkgs,
}:
pkgs.dockerTools.streamLayeredImage {
  name = "${drv.pname}";
  tag = "${drv.version}";
  created = "now";
  contents = [
    drv
    pkgs.dockerTools.caCertificates
  ];
  config = {
    Cmd = [
      "${pkgs.lib.meta.getExe drv}"
    ];
  };
}
