{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hekate";
  version = "6.5.4";

  # The asset name carries the bundled Nyx version, which does not follow from
  # the release tag.
  asset = "hekate_ctcaer_6.5.4_Nyx_1.9.4.zip";

  src = fetchurl {
    url = "https://github.com/CTCaer/hekate/releases/download/v${finalAttrs.version}/${finalAttrs.asset}";
    hash = "sha256-pe5PqpVvH/5J/dMdeVvj/VVsjf/Zy+1pzsfP+SuLQ/Y=";
  };

  nativeBuildInputs = [ unzip ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hekate
    unzip -q $src -d $out/share/hekate

    runHook postInstall
  '';

  meta = {
    description = "GUI based Nintendo Switch bootloader";
    longDescription = ''
      SD card payload, not a Linux program: bootloader/ unpacks to the card root
      and hekate_ctcaer_*.bin is injected over USB. Nothing lands in $out/bin.
    '';
    homepage = "https://github.com/CTCaer/hekate";
    changelog = "https://github.com/CTCaer/hekate/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.platforms.all;
  };
})
