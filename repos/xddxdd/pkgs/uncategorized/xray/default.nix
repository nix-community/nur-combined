{ lib
, sources
, buildGoModule
, makeWrapper
, ...
}:

buildGoModule {
  pname = "xray-core";
  inherit (sources.xray) version src;
  vendorSha256 = "sha256-QAF/05/5toP31a/l7mTIetFhXuAKsT69OI1K/gMXei0=";

  nativeBuildInputs = [ makeWrapper ];

  doCheck = false;

  buildPhase = ''
    buildFlagsArray=(-v -p $NIX_BUILD_CORES -ldflags="-s -w")
    runHook preBuild
    go build "''${buildFlagsArray[@]}" -o xray ./main
    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin $out/opt
    install -Dm755 xray -t $out/opt
    ln -sf ${sources.v2fly-geoip.src} $out/opt/geoip.dat
    ln -sf ${sources.v2fly-geosite.src} $out/opt/geosite.dat
    ln -sf ${sources.v2fly-private.src} $out/opt/private.dat

    makeWrapper "$out/opt/xray" "$out/bin/v2ray" \
      --chdir "$out/opt"
    makeWrapper "$out/opt/xray" "$out/bin/xray" \
      --chdir "$out/opt"
  '';

  meta = with lib; {
    description = "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration.";
    homepage = "https://t.me/projectXray";
    license = licenses.mpl20;
  };
}
