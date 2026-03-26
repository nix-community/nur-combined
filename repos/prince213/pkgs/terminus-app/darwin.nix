{
  pname,
  version,
  src,
  meta,

  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Termius.app $out/Applications

    runHook postInstall
  '';
}
