{ lib, stdenv, fetchfromgh, undmg, darktable }:

stdenv.mkDerivation (finalAttrs: {
  pname = "darktable-bin";
  version = "4.4.2";

  src = fetchfromgh {
    owner = "darktable-org";
    repo = "darktable";
    name = "darktable-${finalAttrs.version}-x86_64.dmg";
    hash = "sha256-nrhOoEHarXBKjUIm2MfLp3Ui3NAD1xZpYYabHPqprJo=";
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

  meta = with lib;
    darktable.meta // {
      maintainers = [ maintainers.sikmir ];
      platforms = [ "x86_64-darwin" ];
      skip.ci = true;
    };
})
