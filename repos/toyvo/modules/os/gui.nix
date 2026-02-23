{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles;
in
{
  options.profiles.gui.enable = lib.mkEnableOption "GUI Applications" // {
    # macs will always have GUI enabled
    default = pkgs.stdenv.isDarwin;
  };

  config = lib.mkIf cfg.gui.enable {
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-lgc-plus
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-emoji-blob-bin
      noto-fonts-monochrome-emoji
      monaspace
      nerd-fonts.monaspace
      nerd-fonts.symbols-only
    ];
    environment = {
      systemPackages =
        with pkgs;
        [
          brave
          inkscape
        ]
        ++ lib.optionals stdenv.isLinux [
          element-desktop
          firefox
          ghostty
          gimp
          # yubikey-manager-qt
          # yubioath-flutter
        ]
        ++ lib.optionals (stdenv.system == "x86_64-linux") [
          proton-pass
          protonvpn-gui
          protonmail-desktop
        ]
        # ++
        #   lib.optionals
        #     (builtins.elem system [
        #       "aarch64-darwin"
        #       "x86_64-darwin"
        #       "x86_64-linux"
        #     ])
        #     [
        #       logseq
        #     ]
        ++ lib.optionals stdenv.isDarwin [
          appcleaner
          gimp2
          pinentry_mac
          utm
          warp-terminal
        ];
    };
  };
}
