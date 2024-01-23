{ lib, stdenv, fetchfromgh, undmg, python3Packages, qutebrowser }:

stdenv.mkDerivation (finalAttrs: {
  pname = "qutebrowser-bin";
  version = "3.1.0";

  src = fetchfromgh {
    owner = "qutebrowser";
    repo = "qutebrowser";
    name = "qutebrowser-${finalAttrs.version}.dmg";
    hash = "sha256-AvuuwUnxMcr2ekZ/O1FL/4IizV1aTMhXNrbf1SwNY7U=";
    version = "v${finalAttrs.version}";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ undmg python3Packages.wrapPython ];

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

  meta = with lib;
    qutebrowser.meta // {
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      maintainers = [ maintainers.sikmir ];
      platforms = [ "x86_64-darwin" ];
      skip.ci = true;
    };
})
