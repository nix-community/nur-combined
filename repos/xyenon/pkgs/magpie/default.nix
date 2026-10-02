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
  versionCheckHook,
  nix-update-script,
  coreutils,
  xdg-utils,
  xcbuild,
  guiSupport ? true,
}:

buildGoModule (finalAttrs: {
  __structuredAttrs = true;

  pname = "magpie";
  version = "0.1.661";

  src = fetchFromGitHub {
    owner = "yetone";
    repo = "magpie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/Z+84p6rY7zxhmGjVMlWdf8uD6SDdSlvVpiNZVREIEQ=";
  };

  vendorHash = "sha256-XEaHZVw3co0yUV6fLUlSkvg9LlroKFj2B2sjMW1e6BU=";

  patches = lib.optionals (guiSupport && stdenv.hostPlatform.isLinux) [
    ./linux-launcher.patch
  ];
  postPatch = lib.optionalString (guiSupport && stdenv.hostPlatform.isLinux) ''
    substituteInPlace internal/autostart/autostart.go internal/autostart/launcher_linux_test.go \
      --replace-fail '@magpie@' "$out/bin/magpie"
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
    substituteInPlace internal/agent/cliupdate_test.go internal/library/rtk_upgrade_test.go \
      --replace-fail '/bin/cat' '${lib.getExe' coreutils "cat"}'
    substituteInPlace internal/library/rtk_test.go \
      --replace-fail '/bin/mkdir' '${lib.getExe' coreutils "mkdir"}'
    # The source policy check must not scan dependencies added by buildGoModule.
    substituteInPlace internal/proc/proc_test.go \
      --replace-fail 'd.Name() == "node_modules"' 'd.Name() == "node_modules" || d.Name() == "vendor"'
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
  nativeCheckInputs = lib.optionals stdenv.hostPlatform.isDarwin [ xcbuild ];
  checkPhase = ''
    runHook preCheck
    go test -tags=${lib.concatStringsSep "," finalAttrs.tags} ./...
    runHook postCheck
  '';

  nativeBuildInputs = lib.optionals (guiSupport && stdenv.hostPlatform.isLinux) [
    pkg-config
    wrapGAppsHook3
    copyDesktopItems
  ];
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
        install -Dm644 internal/gui/icon-1024.png $out/share/icons/hicolor/1024x1024/apps/magpie.png
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
