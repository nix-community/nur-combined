{
  stdenvNoCC,
  sources,
  lib,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.rime-dict) pname version src;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    find $src -name "*.dict.yaml" -exec cp {} $out/share/rime-data/ \;

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "RIME 词库增强";
    homepage = "https://github.com/Iorest/rime-dict";
    license = with lib.licenses; [ unfree ];
  };
})
