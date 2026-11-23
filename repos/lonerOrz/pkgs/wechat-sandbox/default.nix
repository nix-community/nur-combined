{
  lib,
  nixpakApp,
  wechat,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,

  extraModules ? [ ],
  enableCamera ? true,
  fonts ? { },

  xwechatDir ? null,
  xwechatFilesDir ? null,
}:

let
  inherit (nixpakApp) nixpak;

  pname = "wechat-sandbox";
  appId = "com.tencent.WeChat";
  mainProgram = "wechat";
  desktopFileName = "${mainProgram}.desktop";

  wrapped = nixpak {
    inherit extraModules;

    config =
      { sloth, ... }:
      let
        appDir = sloth.appDir;
        configHome = sloth.xdgConfigHome;
        dataHome = sloth.xdgDataHome;
        homeDir = sloth.homeDir;

        dataBind = name: sandboxPath: value: [
          [
            (sloth.mkdir (if value == null then sloth.concat' appDir "/${name}" else value))
            sandboxPath
          ]
        ];
      in
      {
        app = {
          package = lib.mkDefault wechat;
          binPath = lib.mkDefault "bin/${mainProgram}";
        };

        flatpak = {
          appId = lib.mkDefault appId;

          desktopFile = lib.mkDefault desktopFileName;
        };

        dbus.policies."org.kde.*" = lib.mkDefault "own";

        nixpakCommon.fonts = lib.mkMerge [
          { enable = lib.mkDefault true; }
          fonts
        ];

        bubblewrap = {
          env = {
            GTK_APPLICATION_PREFER_DARK_THEME = lib.mkDefault (
              sloth.envOr "GTK_APPLICATION_PREFER_DARK_THEME" "1"
            );

            GTK_USE_PORTAL = lib.mkDefault "0";
            QT_QPA_PLATFORMTHEME = lib.mkDefault "";
            LC_NUMERIC = lib.mkDefault "C";
          };

          bind.dev = lib.optional enableCamera "/dev/video0";

          bind.rw =
            dataBind "xwechat" (sloth.concat' homeDir "/.xwechat") xwechatDir
            ++ dataBind "xwechat_files" (sloth.concat' homeDir "/xwechat_files") xwechatFilesDir
            ++ [
              sloth.xdgDownloadDir
            ];

          bind.ro = [
            [
              (sloth.concat' homeDir "/.config/fcitx5")
              (sloth.concat' configHome "/fcitx5")
            ]
            [
              (sloth.concat' homeDir "/.local/share/fcitx5/themes")
              (sloth.concat' dataHome "/fcitx5/themes")
            ]

            (sloth.concat' configHome "/kdeglobals")
            (sloth.concat' configHome "/gtk-2.0")
            (sloth.concat' configHome "/gtk-3.0")
            (sloth.concat' configHome "/gtk-4.0")
            (sloth.concat' configHome "/fontconfig")
            (sloth.concat' configHome "/dconf")

            "/sys/dev"
            "/sys/devices"
          ];
        };
      };
  };

  desktopMask = runCommandLocal "wechat-desktop-mask" { } ''
    mkdir -p "$out/share/applications"

    for name in ${wrapped.config.flatpak.desktopFile} ${wrapped.config.flatpak.appId}.desktop; do
      cat > "$out/share/applications/$name" <<'EOF'
    [Desktop Entry]
    Type=Application
    Name=WeChat
    Hidden=true
    NoDisplay=true
    EOF
    done
  '';

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "WeChat";
    genericName = "WeChat";
    comment = "Tencent WeChat";
    exec = "${wrapped.config.script}/bin/${mainProgram} %U";
    icon = "wechat";
    type = "Application";
    startupNotify = true;
    terminal = false;
    categories = [ "Utility" ];

    extraConfig = {
      "Name[zh_CN]" = "微信";
      "Comment[zh_CN]" = "微信桌面版";
      "X-Flatpak" = wrapped.config.flatpak.appId;
    };
  };

in
buildEnv {
  name = pname;

  paths = [
    (lib.hiPrio desktopMask)
    wrapped.config.env
    desktopItem
  ];

  passthru.autoUpdate = false;

  meta = {
    description = "Tencent WeChat sandboxed application";
    mainProgram = mainProgram;
    maintainers = with lib.maintainers; [ lonerOrz ];
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.platforms.linux;
  };
}
