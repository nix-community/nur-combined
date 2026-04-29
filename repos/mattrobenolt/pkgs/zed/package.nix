{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeDesktopItem,
  copyDesktopItems,
  alsa-lib,
  version,
  hashes,
  channel,
}:

let
  isPreview = channel == "preview";

  targets = {
    "x86_64-linux" = "x86_64";
    "aarch64-linux" = "aarch64";
  };

  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

in
stdenv.mkDerivation {
  pname = if isPreview then "zed-preview" else "zed";
  inherit version;

  src = fetchurl {
    url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-${target}.tar.gz";
    hash = hashes.${stdenv.hostPlatform.system};
  };

  sourceRoot = if isPreview then "zed-preview.app" else "zed.app";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    stdenv.cc.cc.lib
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec $out/lib $out/share

    install -m755 bin/zed $out/bin/zed
    install -m755 libexec/zed-editor $out/libexec/zed-editor
    cp -P lib/*.so* $out/lib/
    cp -r share/icons $out/share/

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = if isPreview then "zed-preview" else "zed";
      exec = "zed %F";
      icon = "zed";
      comment = "A high-performance, multiplayer code editor";
      desktopName = if isPreview then "Zed Preview" else "Zed";
      genericName = "Text Editor";
      categories = [
        "TextEditor"
        "Development"
      ];
      mimeTypes = [
        "text/plain"
        "inode/directory"
      ];
    })
  ];

  meta = with lib; {
    description =
      "A high-performance, multiplayer code editor" + lib.optionalString isPreview " (Preview)";
    homepage = "https://zed.dev";
    license = licenses.gpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
    mainProgram = "zed";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
