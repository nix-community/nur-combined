{
  sources,
  version,
  lib,
  stdenvNoCC,
  findutils,
}:
stdenvNoCC.mkDerivation (_final: {
  inherit (sources) pname src;
  inherit version;

  nativeBuildInputs = [ findutils ];

  installPhase = ''
    runHook preInstall

    find . -name '*.ttf' -exec install -Dt $out/share/fonts/truetype {} \;

    runHook postInstall
  '';

  meta = {
    homepage = "https://lxgw.github.io/";
    description = "Open-source Chinese GuoBiao font derived from Fontworks' Klee One";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
  };
})
