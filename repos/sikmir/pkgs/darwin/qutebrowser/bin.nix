{ lib, stdenv, fetchfromgh, undmg }:

stdenv.mkDerivation (finalAttrs: {
  pname = "qutebrowser-bin";
  version = "2.5.3";

  src = fetchfromgh {
    owner = "qutebrowser";
    repo = "qutebrowser";
    name = "qutebrowser-${finalAttrs.version}.dmg";
    hash = "sha256-T3DMZhIuXxI1tDCEi7knu6lscGCVSjU1UW76SaKd1N4=";
    version = "v${finalAttrs.version}";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "A keyboard-driven, vim-like browser";
    homepage = "https://qutebrowser.org";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
})
