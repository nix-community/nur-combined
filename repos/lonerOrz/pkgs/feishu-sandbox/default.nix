{
  lib,
  nixpakApp,
  feishu,
  runCommandLocal,
  runtimeShell,
  buildEnv,
  makeDesktopItem,

  extraModules ? [ ],
  enableCamera ? true,
  fonts ? { },

  # Directory the launcher changes into before exec'ing Feishu. Expanded by
  # the shell, so `$HOME` works; `null` keeps the caller's working directory.
  workingDirectory ? "$HOME/Downloads",
}:

let
  inherit (nixpakApp) nixpak;

  pname = "feishu-sandbox";
  appId = "com.bytedance.feishu";
  mainProgram = "bytedance-feishu";

  launcher = runCommandLocal "feishu-launcher" { } ''
    mkdir -p "$out/bin"

    cat > "$out/bin/${mainProgram}" <<'EOF'
    #!${runtimeShell}
    ${lib.optionalString (workingDirectory != null) ''
      cd "${workingDirectory}" 2>/dev/null || cd "$HOME"
    ''}
    exec ${feishu}/bin/${mainProgram} "$@"
    EOF

    chmod 755 "$out/bin/${mainProgram}"
  '';

  appPackage = buildEnv {
    name = "feishu-app";

    paths = [
      (lib.hiPrio launcher)
      feishu
    ];

    meta.mainProgram = mainProgram;
  };

  wrapped = nixpak {
    inherit extraModules;

    config =
      { sloth, ... }:
      {
        app = {
          package = lib.mkDefault appPackage;
          binPath = lib.mkDefault "bin/${mainProgram}";
        };

        flatpak = {
          appId = lib.mkDefault appId;

          # NixPak renames this entry to `${appId}.desktop` and masks the
          # original, so the upstream file name has to be spelled out.
          desktopFile = lib.mkDefault "bytedance-feishu.desktop";
        };

        nixpakCommon.fonts = lib.mkMerge [
          { enable = lib.mkDefault true; }
          fonts
        ];

        bubblewrap = {
          bind.dev = lib.optional enableCamera "/dev/video0";

          bind.rw = [
            sloth.xdgDownloadDir
          ];

          bind.ro = [
            (sloth.concat' sloth.xdgConfigHome "/kdeglobals")
            (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
            (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
            (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
            (sloth.concat' sloth.xdgConfigHome "/dconf")
          ];
        };
      };
  };

  desktopMask = runCommandLocal "feishu-desktop-mask" { } ''
    mkdir -p "$out/share/applications"

    for name in \
      ${wrapped.config.flatpak.desktopFile} \
      ${wrapped.config.flatpak.appId}.desktop
    do
      cat > "$out/share/applications/$name" <<'EOF'
    [Desktop Entry]
    Type=Application
    Name=Feishu
    Hidden=true
    NoDisplay=true
    EOF
    done
  '';

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Feishu";
    genericName = "Feishu";
    comment = "ByteDance Feishu";
    exec = "${wrapped.config.script}/bin/${mainProgram} %U";
    startupNotify = true;
    terminal = false;
    icon = "bytedance-feishu";
    type = "Application";

    categories = [
      "InstantMessaging"
      "Network"
    ];

    extraConfig.X-Flatpak = wrapped.config.flatpak.appId;
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
    description = "ByteDance Feishu sandboxed application";
    mainProgram = mainProgram;
    maintainers = with lib.maintainers; [ lonerOrz ];
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.platforms.linux;
  };
}
