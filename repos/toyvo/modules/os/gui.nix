{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg;
  # nixpkgs tracks the beta channel but is stuck on 0.10.3-beta.72.
  # Override to the latest beta until upstream catches up.
  # Check https://github.com/abue-ammar/tinycast/releases and drop this
  # override once nixpkgs ships >= the version below.
  tinycast-latest = pkgs.tinycast.overrideAttrs {
    version = "0.11.6-beta.102";
    src = pkgs.fetchurl {
      url = "https://github.com/abue-ammar/tinycast/releases/download/v0.11.6-beta.102/Tinycast-0.11.6-beta.102.dmg";
      hash = "sha256-iL8hthkpDA1HIam9CBSOxqEdqPHW/RKKiwTnrYDClrU=";
    };
  };
in
{
  options.nixcfg.gui.enable = lib.mkEnableOption "GUI Applications" // {
    # macs will always have GUI enabled
    default = pkgs.stdenv.hostPlatform.isDarwin;
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
          # brave
          inkscape
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          element-desktop
          firefox
          ghostty
          gimp
          # yubikey-manager-qt
          # yubioath-flutter
        ]
        ++ lib.optionals (stdenv.system == "x86_64-linux") [
          proton-pass
          proton-vpn
          protonmail-desktop
        ]
        # ++
        #   lib.optionals
        #     (builtins.elem system [
        #       "aarch64-darwin"
        #       "x86_64-linux"
        #     ])
        #     [
        #       logseq
        #     ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [
          appcleaner
          # gimp2
          pinentry_mac
          utm
          # warp-terminal
          tinycast-latest
        ];
    };
  };
}
