# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  # Define model packages first (no dependencies)
  sr-vulkan-model-waifu2x = pkgs.callPackage ./pkgs/sr-vulkan-model-waifu2x.nix {};
  sr-vulkan-model-realcugan = pkgs.callPackage ./pkgs/sr-vulkan-model-realcugan.nix {};
  sr-vulkan-model-realesrgan = pkgs.callPackage ./pkgs/sr-vulkan-model-realesrgan.nix {};
  sr-vulkan-model-realsr = pkgs.callPackage ./pkgs/sr-vulkan-model-realsr.nix {};

  sr-vulkan-models = [
    sr-vulkan-model-waifu2x
    sr-vulkan-model-realcugan
    sr-vulkan-model-realesrgan
    sr-vulkan-model-realsr
  ];

  # sr-vulkan with models linked in its site-packages
  sr-vulkan-with-models = pkgs.callPackage ./pkgs/sr-vulkan.nix {
    inherit sr-vulkan-models;
  };
in {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # SR Vulkan packages
  inherit
    sr-vulkan-model-waifu2x
    sr-vulkan-model-realcugan
    sr-vulkan-model-realesrgan
    sr-vulkan-model-realsr
    ;

  # Base sr-vulkan without models (for custom use)
  sr-vulkan = pkgs.callPackage ./pkgs/sr-vulkan.nix {};

  fortune-mod-zh = pkgs.callPackage ./pkgs/fortune-mod-zh.nix {};
  fortune-mod-hitokoto = pkgs.callPackage ./pkgs/fortune-mod-hitokoto.nix {};

  JMComic-qt = pkgs.callPackage ./pkgs/JMComic-qt.nix {
    sr-vulkan = sr-vulkan-with-models;
  };
  picacg-qt = pkgs.callPackage ./pkgs/picacg-qt.nix {
    sr-vulkan = sr-vulkan-with-models;
  };

  mikusays = pkgs.callPackage ./pkgs/mikusays.nix {};
  sddm-eucalyptus-drop = pkgs.callPackage ./pkgs/sddm-eucalyptus-drop.nix {};
  wechat-web-devtools-linux = pkgs.callPackage ./pkgs/wechat-web-devtools-linux.nix {};
  zsh-url-highlighter = pkgs.callPackage ./pkgs/zsh-url-highlighter.nix {};
  waybar-vd = pkgs.callPackage ./pkgs/waybar-vd {};
  mihomo-smart = pkgs.callPackage ./pkgs/mihomo-smart.nix {};
  # Fladder handled separately using optionalAttrs
  StartLive = pkgs.callPackage ./pkgs/StartLive.nix {};
  bilibili_live_tui = pkgs.callPackage ./pkgs/bilibili_live_tui.nix {};
  Fladder = pkgs.callPackage ./pkgs/Fladder {};
}
