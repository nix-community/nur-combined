{
  lib,
  stdenv,
  fetchfromgh,
  undmg,
  python3Packages,
  qutebrowser,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qutebrowser-bin";
  version = "3.5.0";

  src = fetchfromgh {
    owner = "qutebrowser";
    repo = "qutebrowser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8kBdHGcrAt/b38dU2um90cFLwel2AuejOdNTeOtj2BY=";
    name = "qutebrowser-${finalAttrs.version}-x86_64.dmg";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    undmg
    python3Packages.wrapPython
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  postInstall = ''
    tar -C $out/Applications/qutebrowser.app/Contents/Resources \
      --strip-components=2 -xvzf ${qutebrowser.src} \
      qutebrowser-${qutebrowser.version}/misc/userscripts/qute-pass

    buildPythonPath ${python3Packages.tldextract};
    patchPythonScript $out/Applications/qutebrowser.app/Contents/Resources/userscripts/qute-pass
  '';

  passthru.userscripts = "${finalAttrs.finalPackage}/Applications/qutebrowser.app/Contents/Resources/userscripts";

  meta = qutebrowser.meta // {
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
})
