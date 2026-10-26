{
  lib,
  stdenvNoCC,
  fetchurl,
  asar,
  dpkg,
  electron,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-meet-bin";
  version = "1.0.14";

  src = fetchurl {
    url = "https://proton.me/download/meet/linux/${finalAttrs.version}/ProtonMeet-desktop.deb";
    hash = "sha256-7j90Yk7zddMVjEnZHuHPUwMsy3Cak3uuZU7EgBlh6QM=";
  };

  nativeBuildInputs = [
    asar
    dpkg
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  # Use Nix's Electron runtime, with the loading/error pages beside our ASAR.
  postPatch = ''
    asar extract usr/lib/proton-meet/resources/app.asar app
    substituteInPlace app/.webpack/main/index.js \
      --replace-fail 'process.resourcesPath' "'$out/share/proton-meet'"
    asar pack app usr/lib/proton-meet/resources/app.asar
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/proton-meet
    cp -r usr/share/applications usr/share/icons $out/share/
    cp -r usr/lib/proton-meet/resources/. $out/share/proton-meet/

    makeWrapper ${lib.getExe electron} $out/bin/proton-meet \
      --add-flags $out/share/proton-meet/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=auto --enable-wayland-ime=true}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  meta = {
    description = "End-to-end encrypted video conferencing client";
    homepage = "https://proton.me/meet";
    downloadPage = "https://proton.me/meet/download";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ iamanaws ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "proton-meet";
  };
})
