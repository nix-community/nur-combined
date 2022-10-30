{ lib
, fetchFromGitHub
, sources
, linkFarm
, buildGoModule
, runCommand
, makeWrapper
}:

let
  inherit (sources.xray) version src;
  vendorSha256 = "sha256-QAF/05/5toP31a/l7mTIetFhXuAKsT69OI1K/gMXei0=";

  assetsDrv = linkFarm "xray-assets" (lib.mapAttrsToList
    (name: path: {
      inherit name path;
    })
    {
      # MIT licensed
      "geoip.dat" = sources.v2fly-geoip.src;
      "private.dat" = sources.v2fly-private.src;
      "geosite.dat" = sources.v2fly-geosite.src;
    });

  core = buildGoModule rec {
    pname = "xray-core";
    inherit version src vendorSha256;

    doCheck = false;

    buildPhase = ''
      buildFlagsArray=(-v -p $NIX_BUILD_CORES -ldflags="-s -w")
      runHook preBuild
      go build "''${buildFlagsArray[@]}" -o xray ./main
      runHook postBuild
    '';

    installPhase = ''
      install -Dm755 xray -t $out/bin
    '';

    meta = with lib; {
      description = "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration.";
      homepage = "https://t.me/projectXray";
      license = licenses.mpl20;
    };
  };

in
runCommand "xray-${version}"
{
  inherit src version;
  inherit (core) meta;

  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper "${core}/bin/xray" "$out/bin/v2ray" \
    --set-default V2RAY_LOCATION_ASSET ${assetsDrv}
  makeWrapper "${core}/bin/xray" "$out/bin/xray" \
    --set-default V2RAY_LOCATION_ASSET ${assetsDrv}
''
