{
  name,
  pkgs,
}:
pkgs.dockerTools.buildLayeredImage {
  name = "${pkgs."${name}".pname}";
  tag = "${pkgs."${name}".version}";
  created = "now";
  contents = [
    pkgs."${name}"
    pkgs.dockerTools.caCertificates
  ];
  config.Cmd = [
    "${pkgs.lib.meta.getExe pkgs."${name}"}"
  ];
}
