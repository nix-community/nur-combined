{ pkgs, ... }:

{
  home = {
    packages = [ pkgs.nixGL.auto.nixGLDefault ];
  };
}
