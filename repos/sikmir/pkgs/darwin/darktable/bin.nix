{
  lib,
  stdenv,
  fetchfromgh,
  undmg,
  darktable,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "darktable-bin";
  version = "5.0.0";

  src = fetchfromgh {
    owner = "darktable-org";
    repo = "darktable";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-P0nPtjlYJpuZBlz2tQFnjU5j8kV+4ZFbzX/6Df753P0=";
    name = "darktable-${finalAttrs.version}-x86_64.dmg";
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
