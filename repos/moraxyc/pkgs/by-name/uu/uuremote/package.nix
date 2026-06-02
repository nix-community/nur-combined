{
  lib,
  stdenvNoCC,
  xar,
  cpio,
  gzip,

  sources,
  source ? sources.uuremote,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  # version = "4.26.0";
  #
  # src = fetchurl {
  #   url = "https://a56.gdl.netease.com/uuyc_${finalAttrs.version}.pkg";
  #   hash = "sha256-P/iJl2+DMpfURicpHKJfqi7Wi2HBWQRtfRYRfsSMSKI=";
  # };

  strictDeps = true;

  nativeBuildInputs = [
    xar
    cpio
    gzip
  ];

  unpackPhase = ''
    runHook preUnpack

    xar -xf "$src"

    pushd UURemote.pkg
    gzip -dc Payload | cpio -idm
    popd

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R UURemote.pkg/Applications/UURemote.app $out/Applications/

    runHook postInstall
  '';

  # use nvfetcher
  # passthru.updateScript = lib.getExe ();

  meta = {
    description = "NetEase UU remote desktop access and control tool";
    homepage = "https://uuyc.163.com";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
