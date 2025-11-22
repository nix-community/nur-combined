{
  lib,
  stdenvNoCC,
  fetchfromgh,
  _7zz,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zed-preview";
  version = "0.214.0-pre";

  src = fetchfromgh {
    owner = "zed-industries";
    repo = "zed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Z3bGgYFwzBp4Knad1d2HEcVWkXbHYI7i3rAWQJeI9v4=";
    name = "Zed-x86_64.dmg";
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
