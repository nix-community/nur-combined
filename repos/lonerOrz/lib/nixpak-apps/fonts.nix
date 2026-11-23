{
  pkgs,
}:

let
  inherit (pkgs) lib;

  defaultPrimaryFont = pkgs.lxgw-wenkai-screen;
  defaultPrimaryFamily = "LXGW WenKai Screen";
  defaultPrimaryFile = "${defaultPrimaryFont}/share/fonts/truetype/LXGWWenKaiScreen.ttf";

  emojiNoAscii =
    pkgs.runCommandLocal "noto-color-emoji-no-ascii"
      {
        nativeBuildInputs = [
          pkgs.python3Packages.fonttools
        ];
      }
      ''
        mkdir -p "$out/share/fonts/noto"

        python3 - "$out" <<'PY'
        import sys
        from fontTools.ttLib import TTFont

        src = "${pkgs.noto-fonts-color-emoji}/share/fonts/noto/NotoColorEmoji.ttf"
        dst = sys.argv[1] + "/share/fonts/noto/NotoColorEmoji.ttf"

        font = TTFont(src)
        for table in font["cmap"].tables:
            for codepoint in list(table.cmap):
                if 0x20 <= codepoint <= 0x7E:
                    del table.cmap[codepoint]
        font.save(dst)
        PY
      '';

  defaultExtraPackages = [
    emojiNoAscii
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
  ];

  canGenerateCache = pkgs.stdenv.hostPlatform.emulatorAvailable pkgs.buildPackages;

  mk =
    {
      name,
      package ? defaultPrimaryFont,
      family ? defaultPrimaryFamily,
      extraPackages ? [ ],
      aliases ? [ ],
      minimal ? false,
    }:

    let
      fontPackages = [ package ] ++ defaultExtraPackages ++ extraPackages;

      fontCache =
        if canGenerateCache && !minimal then
          pkgs.makeFontsCache {
            inherit (pkgs) fontconfig;
            fontDirectories = fontPackages;
          }
        else
          null;

      fontDirectories = lib.concatMapStringsSep "\n" (
        font: "<dir>${lib.escapeXML (toString font)}</dir>"
      ) fontPackages;

      aliasRules = lib.concatMapStringsSep "\n" (alias: ''
        <match target="pattern">
          <test name="family" qual="any">
            <string>${lib.escapeXML alias}</string>
          </test>
          <edit name="family" mode="assign" binding="strong">
            <string>${family}</string>
          </edit>
        </match>
      '') aliases;

      fontConfig = pkgs.writeText "nixpak-fonts.conf" ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          ${fontDirectories}

          <match target="pattern">
            <edit name="family" mode="prepend" binding="strong">
              <string>${family}</string>
            </edit>
          </match>

          ${aliasRules}

          ${lib.optionalString (fontCache != null) ''
            <cachedir>${fontCache}</cachedir>
          ''}

          <cachedir prefix="xdg">fontconfig</cachedir>
        </fontconfig>
      '';
    in
    if minimal then
      pkgs.runCommandLocal name { } ''
        install -Dm644 \
          ${fontConfig} \
          "$out/etc/fonts/fonts.conf"
      ''
    else
      pkgs.runCommandLocal name { } ''
        mkdir -p "$out/etc/fonts"

        cp -rL \
          "${pkgs.fontconfig.out}/etc/fonts/conf.d" \
          "$out/etc/fonts/conf.d"

        chmod -R u+w "$out/etc/fonts/conf.d"

        install -Dm644 \
          "${pkgs.fontconfig.out}/etc/fonts/fonts.conf" \
          "$out/etc/fonts/fonts.conf"

        install -Dm644 \
          ${fontConfig} \
          "$out/etc/fonts/conf.d/00-nixpak-fonts.conf"
      '';

in
{
  inherit
    defaultPrimaryFont
    defaultPrimaryFamily
    defaultPrimaryFile
    emojiNoAscii
    mk
    ;
}
