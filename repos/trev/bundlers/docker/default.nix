{
  drv,
  pkgs,
}:
pkgs.dockerTools.buildLayeredImage {
  name = "${drv.pname}";
  tag = "${drv.version}";
  created = "now";
  meta = drv.meta;
  contents = with pkgs; [
    dockerTools.caCertificates
    drv
  ];
  config.Cmd = [
    "${pkgs.lib.meta.getExe drv}"
  ];
}
