{
  lib,
  nixpakApp,
  qq,
  runCommandLocal,
  runtimeShell,
  coreutils,
  buildEnv,

  extraModules ? [ ],
  enableCamera ? true,
  fonts ? { },
  replaceBundledFonts ? true,
}:

let
  inherit (nixpakApp) nixpak;

  pname = "qq-sandbox";
  appId = "com.tencent.QQ";
  mainProgram = "qq";
  desktopFileName = "qq.desktop";

  sleep = lib.getExe' coreutils "sleep";

  wrapped = nixpak {
    inherit extraModules;

    config =
      { sloth, config, ... }:
      let
        inherit (config.nixpakCommon.fonts) file;

        qqPatched = runCommandLocal "qq-font-patched" { } ''
          set -euo pipefail
          shopt -s dotglob nullglob

          src="${qq}"
          qqSrc="$src/opt/QQ"
          qqOut="$out/opt/QQ"

          resourceSrc="$qqSrc/resources/app/resource"
          resourceOut="$qqOut/resources/app/resource"

          fontSrc="$resourceSrc/fonts"
          fontOut="$resourceOut/fonts"

          link_dir_except() {
            local srcDir="$1"
            local dstDir="$2"
            local entry name excluded skip

            shift 2
            mkdir -p "$dstDir"

            for entry in "$srcDir"/*; do
              name="''${entry##*/}"
              skip=0

              for excluded in "$@"; do
                if [ "$name" = "$excluded" ]; then
                  skip=1
                  break
                fi
              done

              if [ "$skip" -eq 0 ]; then
                ln -s "$entry" "$dstDir/$name"
              fi
            done
          }

          link_dir_except "$src" "$out" opt bin share
          link_dir_except "$src/opt" "$out/opt" QQ

          link_dir_except "$qqSrc" "$qqOut" resources qq
          link_dir_except "$qqSrc/resources" "$qqOut/resources" app
          link_dir_except "$qqSrc/resources/app" "$qqOut/resources/app" resource

          if [ ! -d "$fontSrc" ]; then
            echo "QQ font directory not found: $fontSrc" >&2
            exit 1
          fi

          mkdir -p "$fontOut"

          for entry in "$fontSrc"/*; do
            name="''${entry##*/}"
            ln -s "$entry" "$fontOut/$name"
          done

          ${lib.optionalString (replaceBundledFonts && file != null) ''
            replace_fonts() {
              local source="$1"
              local name

              shift

              for name in "$@"; do
                rm -f "$fontOut/$name"
                install -m644 "$source" "$fontOut/$name"
              done
            }

            replace_fonts \
              "${nixpakApp.fonts.emojiNoAscii}/share/fonts/noto/NotoColorEmoji.ttf" \
              AppleColorEmoji.ttf \
              AppleColorEmoji-fix.ttf

            replace_fonts \
              "${file}" \
              DIN-Medium.ttf \
              DIN-Regular.ttf \
              DINNextLTPro-QQ.ttf \
              DINNextLTPro.ttf
          ''}

          # Keep the upstream launcher outside bin so NixPak does not rewrite it.
          mkdir -p "$out/bin" "$out/libexec"

          substitute \
            "$src/bin/qq" \
            "$out/libexec/qq-real" \
            --replace-fail "$src" "$out"

          chmod 755 "$out/libexec/qq-real"

          # Reserve two process IDs for StatusNotifierItem.
          cat > "$out/bin/qq" <<EOF
          #!${runtimeShell}

          ${sleep} 2147483647 &
          s1=\$!

          ${sleep} 2147483647 &
          s2=\$!

          "$out/libexec/qq-real" "\$@" &
          app=\$!

          wait "\$app"
          status=\$?

          kill "\$s1" "\$s2" 2>/dev/null || true

          exit "\$status"
          EOF

          chmod 755 "$out/bin/qq"

          if [ ! -f "$qqSrc/qq" ]; then
            echo "QQ executable not found: $qqSrc/qq" >&2
            exit 1
          fi

          install -m755 "$qqSrc/qq" "$qqOut/qq"

          link_dir_except "$src/share" "$out/share" applications

          link_dir_except \
            "$src/share/applications" \
            "$out/share/applications" \
            "${desktopFileName}"

          substitute \
            "$src/share/applications/${desktopFileName}" \
            "$out/share/applications/${desktopFileName}" \
            --replace-fail "$src/bin/qq" "$out/bin/qq"

        '';
      in
      {
        app = {
          package = lib.mkDefault qqPatched;
          binPath = lib.mkDefault "bin/${mainProgram}";
        };

        flatpak = {
          appId = lib.mkDefault appId;
          desktopFile = lib.mkDefault desktopFileName;
        };

        nixpakCommon.fonts = lib.mkMerge [
          { enable = lib.mkDefault true; }
          fonts
        ];

        dbus.policies."org.freedesktop.StatusNotifierItem-5-1" = lib.mkDefault "own";

        bubblewrap = {
          env = {
            GTK_THEME = lib.mkDefault (sloth.envOr "GTK_THEME" "Adwaita:dark");

            GTK_APPLICATION_PREFER_DARK_THEME = lib.mkDefault (
              sloth.envOr "GTK_APPLICATION_PREFER_DARK_THEME" "1"
            );
          };

          bind.dev = lib.optional enableCamera "/dev/video0";

          bind.rw = [
            sloth.xdgDownloadDir
          ];

          bind.ro = [
            [
              (sloth.concat' sloth.homeDir "/.config/fcitx5")
              (sloth.concat' sloth.xdgConfigHome "/fcitx5")
            ]
            [
              (sloth.concat' sloth.homeDir "/.local/share/fcitx5/themes")
              (sloth.concat' sloth.xdgDataHome "/fcitx5/themes")
            ]

            (sloth.concat' sloth.xdgConfigHome "/kdeglobals")
            (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
            (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
            (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
            (sloth.concat' sloth.xdgConfigHome "/fontconfig")
            (sloth.concat' sloth.xdgConfigHome "/dconf")

            "/sys/dev"
            "/sys/devices"
          ];
        };
      };
  };

in
buildEnv {
  name = pname;

  paths = [
    wrapped.config.env
  ];

  passthru.autoUpdate = false;

  meta = {
    description = "Tencent QQ sandboxed application";
    mainProgram = mainProgram;
    maintainers = with lib.maintainers; [ lonerOrz ];
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.platforms.linux;
  };
}
