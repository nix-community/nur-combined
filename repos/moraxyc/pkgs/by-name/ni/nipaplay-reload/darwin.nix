{
  stdenvNoCC,
  _7zz,

  meta,
  src,
  version,
  pname,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit
    meta
    src
    version
    pname
    ;

  nativeBuildInputs = [ _7zz ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r NipaPlay.app $out/Applications

    runHook postInstall
  '';
})
