{
  lib,
  stdenv,
  buildGoModule,
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
  bun,
  xdg-utils,
  guiSupport ? true,
}:

let
  linuxGui = guiSupport && stdenv.hostPlatform.isLinux;
  darwinGui = guiSupport && stdenv.hostPlatform.isDarwin;
in
buildGoModule (finalAttrs: {
  __structuredAttrs = true;

  pname = "magpie";
  version = "0.1.2295";

  src = fetchFromGitHub {
    owner = "yetone";
    repo = "magpie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dIJDKnnNRbJA7PXp4TovjqEZZPfuucskAX3zSBgbRZE=";
  };

  vendorHash = "sha256-CSFUYQB28DBs0oQSObJEqu07+b7T7DKxINQVu+lHNUw=";

  # Apply runtime policies before compiling the installed application.
  postPatch = ''
    bash ${./patch.sh} ${stdenv.hostPlatform.parsed.kernel.name} ${lib.boolToString guiSupport} \
      "$out/bin/magpie" ${lib.getExe bun}
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

  doCheck = false;

  nativeBuildInputs = [
    makeWrapper
    ast-grep
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
      startupWMClass = "magpie";
      terminal = false;
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
