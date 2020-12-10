{ pkgs, sources, ... }:
{
  bottom = pkgs.callPackage ./bottom { inherit sources; };
  lfs = pkgs.callPackage ./lfs { inherit sources; };
  pueue = pkgs.callPackage ./pueue { inherit sources; };
  sddmThemes = pkgs.libsForQt5.callPackage ./sddm-themes { inherit sources; };
  yubikey-touch-detector = pkgs.callPackage ./yubikey-touch-detector { inherit sources; };
  lua-language-server = pkgs.callPackage ./lua-language-server { inherit sources; };
  gping = pkgs.callPackage ./gping { inherit sources; };
  fishPlugins = pkgs.recurseIntoAttrs (pkgs.callPackage ./fish-plugins { inherit pkgs sources; });
  vimPlugins = pkgs.recurseIntoAttrs (pkgs.callPackage ./vim-plugins { inherit pkgs sources; });
  neovim-nightly = pkgs.callPackage ./neovim-nightly { inherit pkgs sources; };
  firefoxPlugins = pkgs.recurseIntoAttrs (pkgs.callPackage ./firefox-plugins { });
  firefox-hardened = pkgs.callPackage ./firefox-hardened { inherit pkgs; };
  firefox-hardened-wayland = pkgs.callPackage ./firefox-hardened { inherit pkgs; forceWayland = true; };
  hexokinase = pkgs.callPackage ./hexokinase { inherit pkgs sources; };
}
