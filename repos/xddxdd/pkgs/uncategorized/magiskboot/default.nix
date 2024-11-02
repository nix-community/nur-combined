{
  sources,
  lib,
  stdenvNoCC,
  unzip,
}:
let
  arch =
    if stdenvNoCC.isx86_64 then
      "x86_64"
    else if stdenvNoCC.isx86_32 then
      "x86"
    else if stdenvNoCC.isAarch64 then
      "arm64-v8a"
    else if stdenvNoCC.isAarch32 then
      "armeabi-v7a"
    else
      throw "Unsupported architecture";
in
stdenvNoCC.mkDerivation {
  inherit (sources.magiskboot) pname version src;
  dontUnpack = true;

  nativeBuildInputs = [ unzip ];

  buildPhase = ''
    runHook preBuild

    unzip $src

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 lib/${arch}/libmagiskboot.so $out/bin/magiskboot

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Tool to unpack / repack boot images, parse / patch / extract cpio, patch dtb, hex patch binaries, and compress / decompress files with multiple algorithms";
    homepage = "https://topjohnwu.github.io/Magisk/tools.html";
    license = with lib.licenses; [ gpl3Only ];
  };
}
