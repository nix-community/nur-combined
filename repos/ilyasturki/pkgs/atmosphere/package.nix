{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "atmosphere";
  version = "1.12.1";

  # The asset name carries the bundled hbl and hbmenu versions and a commit
  # abbreviation, none of which follow from the release tag.
  asset = "atmosphere-1.12.1-master-6b0c077b4+hbl-2.4.5+hbmenu-3.6.1.zip";

  src = fetchurl {
    url = "https://github.com/Atmosphere-NX/Atmosphere/releases/download/${finalAttrs.version}/${finalAttrs.asset}";
    hash = "sha256-9CFhs7zhFELqSH64SBEBPPDlulcaeWQyPiBpkLNBopc=";
  };

  fusee = fetchurl {
    url = "https://github.com/Atmosphere-NX/Atmosphere/releases/download/${finalAttrs.version}/fusee.bin";
    hash = "sha256-ZVkBfk31rEGM4J+zR8MtBxZJ+LbT1LrJqHRQX8i+0b0=";
  };

  nativeBuildInputs = [ unzip ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/atmosphere
    unzip -q $src -d $out/share/atmosphere
    install -Dm444 ${finalAttrs.fusee} $out/share/atmosphere/fusee.bin

    runHook postInstall
  '';

  meta = {
    description = "Customized firmware for the Nintendo Switch";
    longDescription = ''
      SD card payload, not a Linux program: the archive unpacks to the card root
      and fusee.bin is injected over USB. Nothing lands in $out/bin.
    '';
    homepage = "https://github.com/Atmosphere-NX/Atmosphere";
    changelog = "https://github.com/Atmosphere-NX/Atmosphere/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.platforms.all;
  };
})
