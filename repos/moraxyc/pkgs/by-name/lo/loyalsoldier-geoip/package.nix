{
  lib,
  stdenvNoCC,
  sources,
  source ? sources.loyalsoldier-geoip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  version = source.date;
  inherit (source) src pname;

  outputs = [
    "out"
    "dat"
    "mmdb"
    "csv"
    "clash"
    "surge"
    "nginx"
    "text"
    "srs"
    "mrs"
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p \
      $out/share/loyalsoldier-geoip \
      $dat/share/loyalsoldier-geoip/dat \
      $mmdb/share/loyalsoldier-geoip/mmdb \
      $csv/share/loyalsoldier-geoip/csv \
      $clash/share/loyalsoldier-geoip/clash \
      $surge/share/loyalsoldier-geoip/surge \
      $nginx/share/loyalsoldier-geoip/nginx \
      $text/share/loyalsoldier-geoip/text \
      $srs/share/loyalsoldier-geoip/srs \
      $mrs/share/loyalsoldier-geoip/mrs

    for file in *.dat; do
      [ -e "$file" ] || continue
      install -Dm644 "$file" "$dat/share/loyalsoldier-geoip/dat/$file"
    done

    for file in *.mmdb; do
      [ -e "$file" ] || continue
      install -Dm644 "$file" "$mmdb/share/loyalsoldier-geoip/mmdb/$file"
    done

    for file in *.csv *.zip *.tar.gz; do
      [ -e "$file" ] || continue
      install -Dm644 "$file" "$csv/share/loyalsoldier-geoip/csv/$file"
    done

    cp -r clash/* $clash/share/loyalsoldier-geoip/clash/
    cp -r surge/* $surge/share/loyalsoldier-geoip/surge/
    cp -r nginx/* $nginx/share/loyalsoldier-geoip/nginx/
    cp -r text/* $text/share/loyalsoldier-geoip/text/
    cp -r srs/* $srs/share/loyalsoldier-geoip/srs/
    cp -r mrs/* $mrs/share/loyalsoldier-geoip/mrs/

    runHook postInstall
  '';

  meta = {
    description = "Enhanced edition of GeoIP";
    homepage = "https://github.com/Loyalsoldier/geoip";
    licenses = with lib.licenses; [
      gpl3Only
      cc-by-sa-40
    ];
  };
})
