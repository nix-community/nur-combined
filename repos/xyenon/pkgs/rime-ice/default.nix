{
  isUnstable ? false,
  sources,
  stdenvNoCC,
  lib,
  yq-go,
}:

let
  latestTag = sources.rime-ice.version;
  source = with sources; if isUnstable then rime-ice-unstable else rime-ice;
  version = if isUnstable then "${latestTag}-unstable-${source.date}" else source.version;
in
stdenvNoCC.mkDerivation {
  inherit (source) pname src;
  inherit version;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    install_files=$('${lib.getExe yq-go}' eval '.install_files | split(" ") | map(. | sub("/.*", "")) | unique | join("\n")' "$src/others/recipes/full.recipe.yaml")
    for file in $install_files; do
      cp -r "$src/$file" "$out/share/rime-data/"
    done

    runHook postInstall
  '';

  meta = {
    description = "Rime 配置：雾凇拼音 | 长期维护的简体词库";
    homepage = "https://github.com/iDvel/rime-ice";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
