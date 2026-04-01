{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  electron_41,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
}:

buildNpmPackage rec {
  pname = "imfile-desktop";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "imfile-io";
    repo = "imfile-desktop";
    tag = "v${version}";
    hash = "sha256-joEAN8zhfx+zm5KiAl3ivAXE7R5NLom2SqZ5lBnBEkg=";
  };

  npmDepsHash = "sha256-yRWYSFxjYI5HQTImpvuznQw9X0yKAtjNzswIMAAUDXo=";
  npmDepsFetcherVersion = 2;
  npmBuildScript = "build:github";
  npmInstallFlags = [ "--ignore-scripts" ];
  makeCacheWritable = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    npm_config_nodedir = "${electron_41.headers}";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  postInstall = ''
    mkdir -p $out/share/${pname}
    cp -r dist src static package.json node_modules $out/share/${pname}/

    install -Dm644 static/512x512.png \
      $out/share/icons/hicolor/512x512/apps/${pname}.png

    makeWrapper ${lib.getExe electron_41} $out/bin/${pname} \
      --add-flags $out/share/${pname} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "imFile";
      comment = "A full-featured download manager";
      exec = "${pname} %U";
      icon = pname;
      categories = [
        "Network"
        "FileTransfer"
      ];
    })
  ];

  meta = {
    description = "A full-featured download manager";
    homepage = "https://github.com/imfile-io/imfile-desktop";
    license = lib.licenses.mit;
    mainProgram = pname;
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ ];
  };
}
