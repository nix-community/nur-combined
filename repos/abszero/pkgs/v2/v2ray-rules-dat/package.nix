{
  stdenvNoCC,
  lib,
  fetchurl,
}:

let
  version = "202611072203";
  geoipHash = "0k1qjxr0agkpwsah597355inv3gvxp7gj1gkf7wc7kf1c6w8mdwh";
  geositeHash = "15c0pl9yc0rd2rimdq3m1py7q92ysbdnxwxar4nd8blpxjzxfplp";

  repo = "https://github.com/Loyalsoldier/v2ray-rules-dat";
  geoip = fetchurl {
    url = "${repo}/releases/download/${version}/geoip.dat";
    sha256 = geoipHash;
  };
  geosite = fetchurl {
    url = "${repo}/releases/download/${version}/geosite.dat";
    sha256 = geositeHash;
  };
in

stdenvNoCC.mkDerivation {
  pname = "v2ray-rules-dat";
  inherit version;

  srcs = [
    geoip
    geosite
  ];

  outputs = [
    "out"
    "geoip"
    "geosite"
  ];

  unpackPhase = ''
    mkdir -p source
    cd source
    for src in $srcs; do
      cp $src $(stripHash $src)
    done
  '';

  dontConfigure = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    install -Dm444 -t "$geoip/share/v2ray" geoip.dat
    install -Dm444 -t "$geosite/share/v2ray" geosite.dat

    runHook postInstall
  '';

  dontFixup = true;

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Enhanced edition of V2Ray rules dat files";
    homepage = repo;
    downloadPage = "${repo}/releases";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ weathercold ];
    outputsToInstall = [
      "geoip"
      "geosite"
    ];
    platforms = platforms.all;
  };
}
