{ lib, stdenv, fetchfromgh, undmg, python3Packages, qutebrowser }:

stdenv.mkDerivation (finalAttrs: {
  pname = "qutebrowser-bin";
  version = "3.0.0";

  src = fetchfromgh {
    owner = "qutebrowser";
    repo = "qutebrowser";
    name = "qutebrowser-${finalAttrs.version}.dmg";
    hash = "sha256-TFh5UAjU34s0EstNxQWPxVv0m0YrySKt5yKdh4Hl0pc=";
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
      maintainers = [ maintainers.sikmir ];
      platforms = [ "x86_64-darwin" ];
      skip.ci = true;
    };
})
