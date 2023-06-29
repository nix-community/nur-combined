{ pkgs, ... }:
{
  sane.programs.gthumb.package = pkgs.gthumb.override { withWebservices = false; };
}
