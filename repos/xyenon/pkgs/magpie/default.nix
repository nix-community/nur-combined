{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  gtk3,
  webkitgtk_4_1,
  wrapGAppsHook3,
  makeDesktopItem,
  copyDesktopItems,
  imagemagick,
  ast-grep,
  gotools,
  versionCheckHook,
  nix-update-script,
  coreutils,
  python3,
  bun,
  procps,
  zsh,
  darwin,
  dbus,
  xdg-utils,
  xcbuild,
  guiSupport ? true,
}:

buildGoModule (finalAttrs: {
  __structuredAttrs = true;

  pname = "magpie";
  version = "0.1.1118";

  src = fetchFromGitHub {
    owner = "yetone";
    repo = "magpie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lDMiXvBg4SCgN0PWiPzRj9CfEtEJ7S8GMSxVMm96Kvg=";
  };

  vendorHash = "sha256-dqFc8UTREaRFt3G3DS7IllBx8ysOlcA5JUqGaQ/XlcI=";

  postPatch =
    lib.optionalString (guiSupport && stdenv.hostPlatform.isLinux) ''
      bash ${./linux-launcher.sh} "$out/bin/magpie"
      cp ${./scheme_linux_test.go} internal/gui/nix_scheme_linux_test.go
      cp ${./launcher_linux_test.go} internal/autostart/nix_launcher_linux_test.go
      substituteInPlace internal/autostart/nix_launcher_linux_test.go \
        --replace-fail '@magpie@' "$out/bin/magpie"
    ''
    + lib.optionalString (guiSupport && stdenv.hostPlatform.isDarwin) ''
      # Keep native window tests behind their shared entry point in the build sandbox.
      pattern='func runAppKit($T *testing.T, $$$PARAMS) ($$$RESULTS) {
        $T.Helper()
        $$$BODY
      }'
      ast-grep run --lang go --pattern "$pattern" --globs '*_test.go' \
        --files-with-matches internal/gui
      ast-grep run --lang go --pattern "$pattern" --globs '*_test.go' \
        --rewrite 'func runAppKit($T *testing.T, $$$PARAMS) ($$$RESULTS) {
          $T.Helper()
          $T.Skip("Native AppKit/WebKit windows require a graphical session unavailable to Nix build users")
          $$$BODY
        }' --update-all internal/gui
    '';

  subPackages = [ "." ];
  tags =
    if guiSupport then
      [ "production" ] ++ lib.optional stdenv.hostPlatform.isLinux "gtk3"
    else
      [ "nogui" ];
  env.CGO_ENABLED = if guiSupport then "1" else "0";
  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
  ];

  preCheck = ''
    export MAGPIE_BUN=${lib.getExe bun}
    substituteInPlace main_test.go internal/plugin/main_test.go \
      --replace-fail 'testenv.Main(m)' 'testenv.Offline(); testenv.Main(m)'
    substituteInPlace internal/gateway/automode_test.go \
      --replace-fail '#!/usr/bin/env python3' '#!${lib.getExe python3}'
    # Allow the filesystem change-time clock to advance before the same-size rewrite.
    substituteInPlace internal/sessions/codex_archive_test.go \
      --replace-fail 'writeLines(t, archived, `{"x":2}`)' \
        'time.Sleep(20 * time.Millisecond); writeLines(t, archived, `{"x":2}`)'
    substituteInPlace internal/agent/cliupdate_test.go internal/library/rtk_upgrade_test.go \
      --replace-fail '/bin/cat' '${lib.getExe' coreutils "cat"}'
    substituteInPlace internal/library/rtk_test.go \
      --replace-fail '/bin/mkdir' '${lib.getExe' coreutils "mkdir"}'
    substituteInPlace internal/gui/providers_fetching_unix_test.go \
      --replace-fail '"/usr/bin"' '"${lib.getBin coreutils}/bin"' \
      --replace-fail '"/bin"' '"${lib.getBin coreutils}/bin"'
    # The source policy check must not scan dependencies added by buildGoModule.
    substituteInPlace internal/proc/proc_test.go \
      --replace-fail 'd.Name() == "node_modules"' 'd.Name() == "node_modules" || d.Name() == "vendor"'
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace internal/agent/zed_credential_secret_test.go \
      --replace-fail '"--session"' '"--config-file=${dbus}/share/dbus-1/session.conf"'
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # The AppleScript interpreter is not available in the Darwin build sandbox.
    # Keep the preceding assertions for script generation and cancellation.
    substituteInPlace internal/update/admin_test.go \
      --replace-fail '// AppleScript unescapes it back to the script' \
        'if _, err := exec.LookPath("osascript"); err != nil {
          t.Skip("AppleScript interpreter is unavailable in the build sandbox")
        }
        // AppleScript unescapes it back to the script'
  '';
  nativeCheckInputs = [
    python3
    bun
    zsh
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    dbus
    procps
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    xcbuild
    darwin.adv_cmds
  ];
  checkFlags = [
    # The WSL probe finds omp but reports an empty version in Linux sandbox builds.
    "-skip=^TestWSLProbeFindsBunOmp$"
  ];
  checkPhase = ''
    runHook preCheck
    export GOFLAGS=''${GOFLAGS//-trimpath/}
    buildGoDir test ./...
    runHook postCheck
  '';

  nativeBuildInputs =
    lib.optionals (guiSupport && stdenv.hostPlatform.isLinux) [
      pkg-config
      wrapGAppsHook3
      copyDesktopItems
      imagemagick
      ast-grep
      gotools
    ]
    ++ lib.optional (guiSupport && stdenv.hostPlatform.isDarwin) ast-grep;
  buildInputs = lib.optionals (guiSupport && stdenv.hostPlatform.isLinux) [
    gtk3
    webkitgtk_4_1
  ];

  preFixup = lib.optionalString (guiSupport && stdenv.hostPlatform.isLinux) ''
    gappsWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ xdg-utils ]})
  '';

  desktopItems = lib.optionals (guiSupport && stdenv.hostPlatform.isLinux) [
    (makeDesktopItem {
      name = "magpie";
      desktopName = "magpie";
      comment = "Every agent's model. One place.";
      exec = "magpie %u";
      icon = "magpie";
      categories = [
        "Development"
        "Utility"
      ];
      mimeTypes = [ "x-scheme-handler/magpie" ];
    })
  ];

  postInstall = lib.optionalString guiSupport (
    if stdenv.hostPlatform.isDarwin then
      ''
        mkdir -p $out/Applications/magpie.app/Contents/{MacOS,Resources}
        mv $out/bin/magpie $out/Applications/magpie.app/Contents/MacOS/
        ln -s $out/Applications/magpie.app/Contents/MacOS/magpie $out/bin/magpie
        cp build/darwin/{magpie.icns,Assets.car} $out/Applications/magpie.app/Contents/Resources/
        substitute build/darwin/Info.plist $out/Applications/magpie.app/Contents/Info.plist \
          --replace-fail '@VERSION@' '${finalAttrs.version}'
      ''
    else
      ''
        install -Dm644 internal/gui/icon-1024.png $out/share/icons/hicolor/512x512@2/apps/magpie.png
        mkdir -p $out/share/icons/hicolor/512x512/apps
        magick internal/gui/icon-1024.png -resize 512x512 $out/share/icons/hicolor/512x512/apps/magpie.png
      ''
  );

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  preInstallCheck = ''
    export HOME=$(mktemp -d)
  '';
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Manage models, providers, and accounts for AI coding agents in one place";
    homepage = "https://github.com/yetone/magpie";
    changelog = "https://github.com/yetone/magpie/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "magpie";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
