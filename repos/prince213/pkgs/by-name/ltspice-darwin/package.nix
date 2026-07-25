{
  lib,
  ltspice,
  fetchurl,
  stdenvNoCC,

  # nativeBuildInputs
  cpio,
  makeBinaryWrapper,
  pbzx,
  xar,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (ltspice) pname;
  version = "26.0.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "https://web.archive.org/web/20260724145842if_/https://ltspice.analog.com/software/LTspice_26.pkg";
    hash = "sha256-879Six3xsy0v7PjiC5K8F/5vFyP0K1J1Q8bDCclzn/I=";
  };

  nativeBuildInputs = [
    cpio
    makeBinaryWrapper
    pbzx
    xar
  ];

  unpackPhase = ''
    runHook preUnpack

    xar -xf $src Package.pkg/Payload
    pbzx -n Package.pkg/Payload | cpio -i

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Applications/LTspice.app $out/Applications

    makeWrapper $out/Applications/LTspice.app/Contents/MacOS/LTspice $out/bin/ltspice

    runHook postInstall
  '';

  meta = ltspice.meta // {
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = lib.platforms.darwin;
  };
})
