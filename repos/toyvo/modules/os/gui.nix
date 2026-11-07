{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
let
  cfg = config.nixcfg;
  # herdr-desktop from nixpkgs ships a macOS bundle without
  # NSLocalNetworkUsageDescription, so macOS 15+ Local Network privacy
  # silently blocks its LAN connections (ssh: No route to host) and never
  # prompts. Inject the key and re-sign ad-hoc. This must run in postFixup:
  # fixupPhase strips binaries (invalidating any earlier signature) and runs
  # before installCheckPhase, so signing here covers the final bits and the
  # version check exercises the shipped signature. Linux is unaffected: the
  # appended postFixup is empty there, yielding an identical derivation.
  # TODO: drop once upstream herdrdev/herdr-app ships the key in its bundle
  # (nixpkgs picks it up automatically); then this becomes plain `herdr-desktop`.
  herdr-desktop-fixed = pkgs.herdr-desktop.overrideAttrs (old: {
    postFixup =
      (old.postFixup or "")
      + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        app=$out/Applications/Herdr.app
        /usr/bin/plutil -insert NSLocalNetworkUsageDescription -string "Herdr connects to your machines over SSH on the local network." "$app/Contents/Info.plist" 2>/dev/null \
          || /usr/bin/plutil -replace NSLocalNetworkUsageDescription -string "Herdr connects to your machines over SSH on the local network." "$app/Contents/Info.plist"
        /usr/bin/codesign --force --deep --sign - "$app"
      '';
  });
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
          herdr-desktop-fixed
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
          inputs.nixcfg.packages.${system}.tinycast-beta
        ];
    };
  };
}
