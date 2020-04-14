{ dockerTools }:

attrs:
let
  default = { config.WorkingDir = "/"; };
  input = (default // attrs);
in dockerTools.buildLayeredImage input
