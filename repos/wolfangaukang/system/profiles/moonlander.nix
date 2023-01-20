{ lib
, ignoreLayoutSettings ? false
}:

let
  inherit (lib) mkIf;

in {
  hardware.keyboard.zsa.enable = true;
  services.xserver.inputClassSections = mkIf ignoreLayoutSettings ([
    ''
      Identifier "moonlander"
      MatchIsKeyboard "on"
      MatchProduct "Moonlander"
      Option "XkbLayout" "us"
      Option "XkbVariant" "basic"
    ''
  ]);
}