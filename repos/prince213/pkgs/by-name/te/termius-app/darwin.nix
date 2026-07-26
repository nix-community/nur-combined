{
  pname,
  version,
  src,
  meta,

  stdenvNoCC,

  # nativeBuildInputs
  unzip,
}:

stdenvNoCC.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Termius.app $out/Applications

    runHook postInstall
  '';
}
