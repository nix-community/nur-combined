{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zed-preview";
  version = "0.199.3-pre";

  src = fetchurl {
    url = "https://zed.dev/api/releases/stable/${finalAttrs.version}/Zed-x86_64.dmg";
    hash = "sha256-hW4H0eBdOvu7Mw2/8RFzmb1bIJrmdBgeWcK21uDz5mA=";
  };

  sourceRoot = ".";

  # APFS format is unsupported by undmg
  nativeBuildInputs = [ _7zz ];
  unpackCmd = "7zz x $curSrc";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{Applications,bin}
    cp -r *.app $out/Applications
    ln -s "$out/Applications/Zed Preview.app/Contents/MacOS/cli" $out/bin/zed
    runHook postInstall
  '';

  meta = {
    description = "High-performance, multiplayer code editor";
    homepage = "https://zed.dev";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
})
