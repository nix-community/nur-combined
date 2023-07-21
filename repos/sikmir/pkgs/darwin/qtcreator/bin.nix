{ lib, stdenv, fetchfromgh, p7zip, qtcreator }:

stdenv.mkDerivation (finalAttrs: {
  pname = "qtcreator-bin";
  version = "11.0.0";

  src = fetchfromgh {
    owner = "qt-creator";
    repo = "qt-creator";
    name = "qtcreator-macos-universal-${finalAttrs.version}.7z";
    hash = "sha256-X5XEvtbnQFof1mbdRmB6y31iCI6CCpWOvA3l2FJSzjo=";
    version = "v${finalAttrs.version}";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ p7zip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  meta = with lib;
    qtcreator.meta // {
      maintainers = [ maintainers.sikmir ];
      platforms = [ "x86_64-darwin" ];
      skip.ci = true;
    };
})
