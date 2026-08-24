{
  fetchurl,
  lib,
  nix-update-script,
  stdenv,
  unzip,
}:
let
  arch =
    if stdenv.hostPlatform.isx86_64 then
      "x86_64"
    else if stdenv.hostPlatform.isx86_32 then
      "x86"
    else if stdenv.hostPlatform.isAarch64 then
      "arm64-v8a"
    else if stdenv.hostPlatform.isAarch32 then
      "armeabi-v7a"
    else
      throw "Unsupported architecture";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "magiskboot";
  version = "30.7";
  src = fetchurl {
    url = "https://github.com/topjohnwu/Magisk/releases/download/v30.7/Magisk-v30.7.apk";
    hash = "sha256-4NMtISNTKGD5cSPZJ7G7hsTgjm/YpIv8a1vuCvrp69U=";
  };
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

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/topjohnwu/Magisk/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Tool to unpack / repack boot images, parse / patch / extract cpio, patch dtb, hex patch binaries, and compress / decompress files with multiple algorithms";
    homepage = "https://topjohnwu.github.io/Magisk/tools.html";
    license = with lib.licenses; [ gpl3Only ];
    mainProgram = "magiskboot";
  };
})
