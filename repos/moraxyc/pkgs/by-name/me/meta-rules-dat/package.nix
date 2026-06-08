{
  lib,
  stdenvNoCC,
  sources,
  source ? sources.meta-rules-dat,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  version = source.date;
  inherit (source) src pname;

  outputs = [
    "out"
    "dat"
    "db"
    "metadb"
    "mmdb"
    "mrs"
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    for file in *.sha256sum; do
      [ -e "$file" ] || continue
      sha256sum -c "$file"
    done

    mkdir -p \
      $out/share/meta-rules-dat \
      $dat/share/meta-rules-dat/dat \
      $db/share/meta-rules-dat/db \
      $metadb/share/meta-rules-dat/metadb \
      $mmdb/share/meta-rules-dat/mmdb \
      $mrs/share/meta-rules-dat/mrs

    for file in *.dat; do
      [ -e "$file" ] || continue
      install -Dm644 "$file" "$dat/share/meta-rules-dat/dat/$file"
    done

    for file in *.db; do
      [ -e "$file" ] || continue
      install -Dm644 "$file" "$db/share/meta-rules-dat/db/$file"
    done

    for file in *.metadb; do
      [ -e "$file" ] || continue
      install -Dm644 "$file" "$metadb/share/meta-rules-dat/metadb/$file"
    done

    for file in *.mmdb; do
      [ -e "$file" ] || continue
      install -Dm644 "$file" "$mmdb/share/meta-rules-dat/mmdb/$file"
    done

    for file in *.mrs *.7z; do
      [ -e "$file" ] || continue
      install -Dm644 "$file" "$mrs/share/meta-rules-dat/mrs/$file"
    done

    runHook postInstall
  '';

  meta = {
    description = "Rules dat files for mihomo";
    homepage = "https://github.com/MetaCubeX/meta-rules-dat";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
