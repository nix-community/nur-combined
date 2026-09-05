{
  pname,
  meta,

  lib,
  fetchurl,
  stdenvNoCC,

  # nativeBuildInputs
  cpio,
  makeBinaryWrapper,
  pbzx,
  xar,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname;
  version = "1.15.0-alpha.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "https://github.com/SagerNet/sing-box/releases/download/v${finalAttrs.version}/SFM-${finalAttrs.version}-Universal.pkg";
    hash = "sha256-I8tvpO7j3sI1qkvCVSF2DMpX6/bfBq9aBmwL6kS8u5Y=";
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

  meta = meta // {
    branch = "dev";
    homepage = "https://github.com/SagerNet/sing-box-for-apple";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.platforms.darwin;
  };
})
