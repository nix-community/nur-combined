{
  sources,
  stdenvNoCC,
  lib,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit (sources.rime-ice) pname version src;

  buildPhase = ''
    runHook preBuild

    mv default.yaml rime_ice_suggestion.yaml

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp -r * $out/share/rime-data/

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Rime 配置：雾凇拼音 | 长期维护的简体词库 ";
    homepage = "https://dvel.me/posts/rime-ice/";
    license = licenses.gpl3Only;
  };
}
