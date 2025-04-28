{
  lib,
  stdenv,
  dpkg,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xmclib";
  version = "2.1.16";

  src = ./xmclib-2.1.16-2.deb;

  nativeBuildInputs = [
    dpkg
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    mv ./* $out

    runHook postInstall
  '';

  meta = {
    description = "The XMC Peripheral Library (XMCLib) consists of low-level drivers for the XMC product family peripherals.";
    homepage = "https://github.com/Infineon/mtb-xmclib-cat3";
    license = with lib.licenses; [ bsd3 ];
    platforms = [ "x86_64-linux" ];
  };
})
