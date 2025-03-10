{
  source,
  lib,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation {
  inherit (source) pname version src;

  sourceRoot = "Zen.app";

  nativeBuildInputs = [ undmg ];

  preferLocalBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/Zen.app
    cp -r . $out/Applications/Zen.app

    runHook postInstall
  '';

  meta = {
    description = "Privacy-focused browser that blocks trackers; ads; and other unwanted content while offering the best browsing experience!";
    homepage = "https://github.com/zen-browser/desktop";
    license = lib.licenses.mpl20;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
