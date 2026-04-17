{ inputs, ... }:
{
  flake.modules.nixos.font =
    { lib, pkgs, ... }:
    {
      fonts = {
        enableDefaultPackages = true;
        fontDir.enable = true;
        enableGhostscriptFonts = false;
        packages =
          with (import inputs.nixpkgs {
            system = "x86_64-linux";
            overlays = [ inputs.self.overlays.default ];
          }); [
            # nerd-fonts.fira-code
            nerd-fonts.jetbrains-mono
            source-han-sans
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            twemoji-color-font
            maple-mono.NF-CN-unhinted
            # maple-mono.otf
            # maple-mono.autohint
            cascadia-code
            intel-one-mono
            monaspace
            stix-two
            fira-sans
            plangothic
            maoken-tangyuan
            lxgw-neo-xihei
          ];
        #"HarmonyOS Sans SC" "HarmonyOS Sans TC"
        fontconfig = {
          subpixel = {
            rgba = "none";
            lcdfilter = "none";
          };
          antialias = true;
          hinting.enable = false;
          defaultFonts = lib.mkForce {
            serif = [
              "Noto Serif CJK SC"
              "Noto Serif CJK TC"
              "Noto Serif CJK JP"
              "Noto Serif CJK HK"
              "LXGW Neo XiHei"
            ];
            monospace = [
              "Maple Mono NF CN"
            ];
            sansSerif = [
              "Noto Sans CJK SC"
              "Noto Sans CJK TC"
              "Noto Sans CJK JP"
              "Noto Sans CJK HK"
              "Hanken Grotesk"
              "LXGW Neo XiHei"
            ];
            emoji = [
              "twemoji-color-font"
              "noto-fonts-emoji"
            ];
          };
        };
      };

    };
}
