{
  lib,
  stdenv,
  buildGoModule,
  buildEnv,
  fetchFromGitHub,
  pkg-config,
  gtk3,
  webkitgtk_4_1,
  wrapGAppsHook3,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  imagemagick,
  ast-grep,
  gotools,
  versionCheckHook,
  nix-update-script,
  coreutils,
  bash,
  gawk,
  gnugrep,
  gnused,
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

let
  linuxGui = guiSupport && stdenv.hostPlatform.isLinux;
  darwinGui = guiSupport && stdenv.hostPlatform.isDarwin;
  testTools = buildEnv {
    name = "magpie-test-tools";
    paths = [
      bash
      coreutils
      gawk
      gnugrep
      gnused
      python3
    ];
    pathsToLink = [ "/bin" ];
  };
in
buildGoModule (finalAttrs: {
  __structuredAttrs = true;

  pname = "magpie";
  version = "0.1.1178";

  src = fetchFromGitHub {
    owner = "yetone";
    repo = "magpie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lFKcLWqy+lOFx+/aW7N87QMhDSXi8b6aUpGV2cAqU5E=";
  };

  vendorHash = "sha256-RevP93sHMwgwQxSh4WzKkNIupNQhU/sP3b/g/lpMS+E=";

  postPatch =
    lib.optionalString linuxGui ''
      bash ${./linux-launcher.sh} "$out/bin/magpie"
      cp ${./scheme_linux_test.go} internal/gui/nix_scheme_linux_test.go
      cp ${./launcher_linux_test.go} internal/autostart/nix_launcher_linux_test.go
      substituteInPlace internal/autostart/nix_launcher_linux_test.go \
        --replace-fail '@magpie@' "$out/bin/magpie"
    ''
    + lib.optionalString darwinGui ''
      # Keep the bundle executable native: an exec wrapper breaks Launch Services tracking.
      substituteInPlace main.go \
        --replace-fail 'func main() {' 'func main() {
          os.Setenv("MAGPIE_BUN", "${lib.getExe bun}")'
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
    # Normalize executable fixtures and explicit system PATHs in new tests too.
    GOFLAGS= PATCH_TESTS_SOURCE=${./patch-tests.go} go test ${./patch-tests.go} ${./patch-tests_test.go}
    GOFLAGS= go run ${./patch-tests.go} ${testTools}/bin
    substituteInPlace main_test.go internal/plugin/main_test.go \
      --replace-fail 'testenv.Main(m)' 'testenv.Offline(); testenv.Main(m)'
    # Allow the filesystem change-time clock to advance before the same-size rewrite.
    substituteInPlace internal/sessions/codex_archive_test.go \
      --replace-fail 'writeLines(t, archived, `{"x":2}`)' \
        'time.Sleep(20 * time.Millisecond); writeLines(t, archived, `{"x":2}`)'
    # The source policy check must not scan dependencies added by buildGoModule.
    substituteInPlace internal/proc/proc_test.go \
      --replace-fail 'd.Name() == "node_modules"' 'd.Name() == "node_modules" || d.Name() == "vendor"'
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace internal/agent/zed_credential_secret_test.go \
      --replace-fail '"--session"' '"--config-file=${dbus}/share/dbus-1/session.conf"'
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # xcbuild's plutil lacks Apple's raw extraction format.
    substituteInPlace internal/autostart/autostart_darwin_test.go \
      --replace-fail 'exec.Command("plutil", "-extract", "AssociatedBundleIdentifiers.0", "raw", p)' \
        'exec.Command("${lib.getExe python3}", "-c", `import plistlib, sys; print(plistlib.load(open(sys.argv[1], "rb"))["AssociatedBundleIdentifiers"][0])`, p)'
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
  checkPhase = ''
    runHook preCheck
    export GOFLAGS=''${GOFLAGS//-trimpath/}
    buildGoDir test ./...
    runHook postCheck
  '';

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals linuxGui [
    pkg-config
    wrapGAppsHook3
    copyDesktopItems
    imagemagick
    ast-grep
    gotools
  ]
  ++ lib.optional darwinGui ast-grep;
  buildInputs = lib.optionals linuxGui [
    gtk3
    webkitgtk_4_1
  ];

  preFixup =
    if linuxGui then
      ''
        gappsWrapperArgs+=(
          --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
          --set MAGPIE_BUN ${lib.getExe bun}
        )
      ''
    else
      lib.optionalString (!darwinGui) ''
        wrapProgram "$out/bin/magpie" --set MAGPIE_BUN ${lib.getExe bun}
      '';

  desktopItems = lib.optionals linuxGui [
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
