{
  lib,
  fetchurl,
  sing-box,
  stdenvNoCC,

  # nativeBuildInputs
  cpio,
  makeBinaryWrapper,
  pbzx,
  xar,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sing-box-app";
  version = "1.14.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "https://github.com/SagerNet/sing-box/releases/download/v${finalAttrs.version}/SFM-${finalAttrs.version}-Universal.pkg";
    hash = "sha256-Ux3oBCEp0G/4moRuxRgbVqjWJBS4dYSCbCsj+woKgT4=";
  };

  nativeBuildInputs = [
    cpio
    makeBinaryWrapper
    pbzx
    xar
  ];

  unpackPhase = ''
    runHook preUnpack

    xar -xf $src component-universal.pkg/Payload
    pbzx -n component-universal.pkg/Payload | cpio -i

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r SFM.app $out/Applications

    makeWrapper $out/Applications/SFM.app/Contents/MacOS/SFM $out/bin/sing-box-app

    runHook postInstall
  '';

  meta = sing-box.meta // {
    mainProgram = "sing-box-app";
    platforms = lib.platforms.darwin;
  };
})
