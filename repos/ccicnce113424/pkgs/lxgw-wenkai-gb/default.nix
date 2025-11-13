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

  meta = with lib; {
    homepage = "https://lxgw.github.io/";
    description = "Open-source Chinese GuoBiao font derived from Fontworks' Klee One";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ ccicnce113424 ];
  };
})
