{
  cpio,
  fetchurl,
  gzip,
  lib,
  ltspice,
  makeWrapper,
  stdenvNoCC,
  xar,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (ltspice) pname;
  version = "17.2.4";

  src = fetchurl {
    url = "https://web.archive.org/web/20260404114809if_/https://ltspice.analog.com/software/LTspice.pkg";
    hash = "sha256-GHmV6Sll2xWV/9sbcS2QwVe57PAdErJMS1JZ+S+UJY0=";
  };

  nativeBuildInputs = [
    cpio
    gzip
    makeWrapper
    xar
  ];

  unpackPhase = ''
    runHook preUnpack

    xar -xf $src LTspice.pkg
    gzip -dc LTspice.pkg/Payload | cpio -i

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
