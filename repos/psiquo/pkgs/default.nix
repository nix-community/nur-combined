{ pkgs, ... }:

{
  firefoxAddons = pkgs.recurseIntoAttrs (pkgs.callPackage ./firefox-addons {});
}
