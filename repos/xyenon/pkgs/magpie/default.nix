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
  patchArgs = "-platform ${stdenv.hostPlatform.parsed.kernel.name} -arch ${stdenv.hostPlatform.go.GOARCH} -gui=${lib.boolToString guiSupport} -launcher $out/bin/magpie -bun ${lib.getExe bun}";
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
  version = "0.1.1285";

  src = fetchFromGitHub {
    owner = "yetone";
    repo = "magpie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WF4kQx48zW+eWbleefd7TNNhdAaIJBSPhK9azvJrH3Q=";
  };

  vendorHash = "sha256-pBk3sQZ9/1sVdz2ZteBGgQrI49fDfgsQ8ur7pzM477A=";

  # Apply runtime policies before compiling the installed application.
  postPatch = ''
    export GOCACHE=$TMPDIR/go-cache
    export GOPATH=$TMPDIR/go
    GOFLAGS= GOPROXY=off GOSUMDB=off go run ${./patch.go} -phase runtime ${patchArgs}
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

  # Apply test-only adaptations after compilation to keep them out of the installed binary.
  preCheck = ''
    export MAGPIE_BUN=${lib.getExe bun}
    GOFLAGS= go run ${./patch.go} -phase check ${patchArgs} \
      -tools ${testTools}/bin -templates ${./.} \
      ${lib.optionalString stdenv.hostPlatform.isLinux "-dbus ${dbus}/share/dbus-1/session.conf"}
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
    gotools
  ]
  ++ lib.optionals linuxGui [
    pkg-config
    wrapGAppsHook3
    copyDesktopItems
    imagemagick
  ];
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
