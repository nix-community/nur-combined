{
  lib,
  stdenv,
  fetchfromgh,
  undmg,
  darktable,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "darktable-bin";
  version = "4.6.0";

  src = fetchfromgh {
    owner = "darktable-org";
    repo = "darktable";
    name = "darktable-${finalAttrs.version}-x86_64.dmg";
    hash = "sha256-5OU8wexqWAACnzlyjAJIgqA1dFj1yNjg/xbf4DTnAe0=";
    version = "release-${finalAttrs.version}";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  meta =
    with lib;
    darktable.meta
    // {
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      maintainers = [ maintainers.sikmir ];
      platforms = [ "x86_64-darwin" ];
      skip.ci = true;
    };
})
