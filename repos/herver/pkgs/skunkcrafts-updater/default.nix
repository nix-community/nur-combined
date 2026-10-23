{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  makeWrapper,
  pkgs,
}:

let
  pname = "skunkcrafts-updater";
  # Upstream only publishes an unversioned "latest" AppImage URL
  version = "4.2.7";

  src = fetchurl {
    url = "https://1228098873.rsc.cdn77.org/updater/SkunkcraftsUpdater-x86_64.AppImage";
    hash = "sha256-EvvZ+YjM9g7ZGVXbh1qtS+l0lcsR/y/9DhaIIWvo954=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  # SDL-based GUI; linked against / dlopens these
  runtimeLibs = with pkgs; [
    libGL
    libdrm
    libgbm
    libxkbcommon
    libdecor
    vulkan-loader
    wayland
    dbus
    gtk3
    libayatana-appindicator
    libx11
    libxcursor
    libxext
    libxfixes
    libxi
    libxrandr
    libxscrnsaver
    libxtst
  ];
in
stdenv.mkDerivation {
  inherit pname version;

  src = appimageContents;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = runtimeLibs;

  # Optional: Steam integration and legacy GLES1
  autoPatchelfIgnoreMissingDeps = [
    "libsteam_api.so"
    "libGLES_CM.so.1"
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 usr/bin/SkunkcraftsUpdater_lin $out/lib/${pname}/SkunkcraftsUpdater_lin
    install -Dm755 usr/bin/sku $out/lib/${pname}/sku
    cp -r usr/share $out/
    install -Dm644 SkunkcraftsUpdater.desktop $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=SkunkcraftsUpdater_lin' 'Exec=${pname}'
    install -Dm644 -t $out/share/doc/${pname} README.txt USER_GUIDE.html THIRD_PARTY_NOTICES.txt

    for bin in SkunkcraftsUpdater_lin sku; do
      target=${pname}
      [ "$bin" = sku ] && target=sku
      makeWrapper $out/lib/${pname}/$bin $out/bin/$target \
        --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
    done

    runHook postInstall
  '';

  meta = {
    description = "SkunkCrafts Updater: keeps X-Plane add-ons up to date";
    homepage = "https://forums.x-plane.org/files/file/76635-skunkcrafts-updater/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "skunkcrafts-updater";
  };
}
