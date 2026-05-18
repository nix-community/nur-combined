{
  lib,
  stdenv,
  fetchzip,
  callPackage,

  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,

  brotli,
  bzip2,
  dotnetCorePackages,
  expat,
  fontconfig,
  freetype,
  glib,
  graphite2,
  gtk3,
  harfbuzz,

  libglvnd,

  libice,
  libpng,
  libsm,
  libx11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxtst,

  nss,
  pcre2,
  wayland,
  zlib,
}:

let
  current = lib.trivial.importJSON ./version.json;

  pname = "watt-toolkit";
  version = current.version;

  dotnetRuntime = dotnetCorePackages.aspnetcore_10_0;

  runtimeDependencies = [
    brotli
    bzip2
    expat
    fontconfig
    freetype
    glib
    graphite2
    gtk3
    harfbuzz

    libglvnd

    libice
    libpng
    libsm
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst

    nss
    pcre2
    stdenv.cc.cc.lib
    wayland
    zlib
  ];

  libraryPath = lib.makeLibraryPath runtimeDependencies;

in

stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    url = "https://github.com/BeyondDimension/SteamTools/releases/download/${version}/Steam++_v${version}_linux_x64.tgz";
    hash = current.hash;
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = runtimeDependencies ++ [
    dotnetRuntime
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "net.steampp.app";
      desktopName = "Watt Toolkit";
      exec = "watt-toolkit";
      icon = "net.steampp.app";
      categories = [ "Network" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    appdir=$out/lib/watt-toolkit
    install -d $appdir

    cp -r assemblies $appdir/
    cp -r modules $appdir/
    cp native/linux-x64/* $appdir/assemblies/

    ln -s ${dotnetRuntime}/bin/dotnet $appdir/dotnet
    ln -s $appdir/dotnet $appdir/Steam++

    install -Dm644 \
      Icons/Watt-Toolkit.png \
      $out/share/icons/hicolor/512x512/apps/net.steampp.app.png

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper \
      $out/lib/watt-toolkit/Steam++ \
      $out/bin/watt-toolkit \
      --add-flags "$out/lib/watt-toolkit/assemblies/Steam++.dll" \
      --set DOTNET_ROOT "${dotnetRuntime}" \
      --prefix LD_LIBRARY_PATH : "${libraryPath}"
  '';

  passthru.updateScript =
    let
      versionFile = "pkgs/watt-toolkit/version.json";
    in
    callPackage ../../utils/update.nix {
      inherit versionFile;
      pname = "watt-toolkit";
      updateMethod = "none";
      fetchMetaCommand = "${lib.getExe (
        callPackage ../../utils/json.nix {
          preScript = ''
            VERSION=$(curl -sS https://api.github.com/repos/BeyondDimension/SteamTools/releases/latest | jq -r '.tag_name | ltrimstr("v")')
            CURRENT_VERSION=$(jq -r '.version' "${versionFile}" 2>/dev/null || echo "0.0.0")

            if [ "$(echo -e "$CURRENT_VERSION\n$VERSION" | sort -V | head -n1)" = "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" != "$VERSION" ]; then
              echo "[*] New version available: $VERSION → Updating..." >&2
            else
              echo "[*] Already up to date ($CURRENT_VERSION)" >&2
              cat "${versionFile}"
              exit 0
            fi

            URL="https://github.com/BeyondDimension/SteamTools/releases/download/''${VERSION}/Steam++_v''${VERSION}_linux_x64.tgz"

            echo "[*] Prefetching x86_64 hash..." >&2
            HASH=$(nix-prefetch-url --unpack "$URL" --type sha256 | xargs nix-hash --to-sri --type sha256)
          '';
          commands = {
            version = "echo $VERSION";
            hash = "echo $HASH";
          };
        }
      )}";
    };

  meta = {
    description = "Open-source, cross-platform multifunctional toolkit for Steam";
    homepage = "https://steampp.net/";
    license = lib.licenses.gpl3Only;
    mainProgram = "watt-toolkit";
    maintainers = with lib.maintainers; [ lonerOrz ];
    platforms = [ "x86_64-linux" ];
  };
}
