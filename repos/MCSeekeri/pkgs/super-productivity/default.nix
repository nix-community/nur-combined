{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  electron,
  glib,
  gtk3,
  libdrm,
  libuuid,
  libxkbcommon,
  nspr,
  nss,
  libX11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  zlib,
  libgbm,
  alsa-lib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "super-productivity";
  version = "18.15.1";

  src = fetchurl {
    url = "https://github.com/super-productivity/super-productivity/releases/download/v${finalAttrs.version}/superProductivity-amd64.deb";
    hash = "sha256-2Mp5dzXUr7HY28rQsHDvkcDCwGK202OJluy/Y+0UQ3Y=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    glib
    gtk3
    libdrm
    libuuid
    libxkbcommon
    nspr
    nss
    libX11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    zlib
    libgbm
    alsa-lib
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    mkdir -p build
    dpkg-deb -x $src build
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -r build/opt $out/
    cp -r build/usr/share/icons $out/share/
    cp build/usr/share/applications/*.desktop $out/share/applications/ 2>/dev/null || true

    cat > $out/bin/super-productivity <<WRAPPER
    #!${stdenv.shell}
    exec ${electron}/bin/electron "$out/opt/Super Productivity/resources/app.asar" \
      --no-sandbox "\$@"
    WRAPPER
    chmod +x $out/bin/super-productivity

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "super-productivity";
      desktopName = "Super Productivity";
      comment = "To-do list & time tracker for professionals";
      exec = "super-productivity";
      icon = "super-productivity";
      categories = [ "Utility" "Office" ];
    })
  ];

  meta = {
    description = "To-do list & time tracker for professionals and freelancers";
    homepage = "https://super-productivity.com";
    changelog = "https://github.com/super-productivity/super-productivity/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "super-productivity";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
