{
  cpio,
  fetchurl,
  lib,
  pbzx,
  sing-box,
  stdenvNoCC,
  xar,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sing-box-app";
  version = "1.13.12";

  src = fetchurl {
    url = "https://github.com/SagerNet/sing-box/releases/download/v${finalAttrs.version}/SFM-${finalAttrs.version}-Universal.pkg";
    hash = "sha256-Bc2iBKcNYtbWBZtJ2OmcuFdX3h5P7ftjr7hdEjW29Xo=";
  };

  nativeBuildInputs = [
    cpio
    pbzx
    xar
  ];

  unpackPhase = ''
    runHook preUnpack

    xar -xf $src
    pbzx -n component-universal.pkg/Payload | cpio -i

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -a SFM.app $out/Applications

    runHook postInstall
  '';

  meta = sing-box.meta // {
    platform = lib.platforms.darwin;
  };
})
