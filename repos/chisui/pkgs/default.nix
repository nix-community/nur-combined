{ pkgs }:
{
  firefox-addons = pkgs.recurseIntoAttrs (pkgs.callPackage ./firefox-addons { }); 
  chromium-extensions = pkgs.callPackage ./chromium-extensions { };
  zsh-plugins = pkgs.recurseIntoAttrs (pkgs.callPackage ./zsh-plugins { }); 
}
