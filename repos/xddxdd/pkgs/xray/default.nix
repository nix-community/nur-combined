{ lib
, fetchFromGitHub
, fetchurl
, linkFarm
, buildGoModule
, runCommand
, makeWrapper
, nixosTests
, assetOverrides ? { }
}:

let
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "XTLS";
    repo = "Xray-core";
    rev = "v${version}";
    sha256 = "0smssc2cz6lkkayavlpra4slg3xsp635wqqa92k31vrf01wnx4gk";
  };

  vendorSha256 = "11hfjgpq0j8f4mcp1j7dxfbpsd3rx0ccnlaaay0f2p3vp5dsv1vx";

  assets = {
    # MIT licensed
    "geoip.dat" =
      let
        geoipRev = "202109300030";
        geoipSha256 = "1d2z3ljs0v9rd10cfj8cpiijz3ikkplsymr44f7y90g4dmniwqh0";
      in
      fetchurl {
        url = "https://github.com/v2fly/geoip/releases/download/${geoipRev}/geoip.dat";
        sha256 = geoipSha256;
      };

    # MIT licensed
    "geosite.dat" =
      let
        geositeRev = "20211001023210";
        geositeSha256 = "02d55i1pdndwvmi4v42hnncjng517s0k06gr3yn5krnj2qfjli2w";
      in
      fetchurl {
        url = "https://github.com/v2fly/domain-list-community/releases/download/${geositeRev}/dlc.dat";
        sha256 = geositeSha256;
      };

  } // assetOverrides;

  assetsDrv = linkFarm "xray-assets" (lib.mapAttrsToList
    (name: path: {
      inherit name path;
    })
    assets);

  core = buildGoModule rec {
    pname = "xray-core";
    inherit version src;

    inherit vendorSha256;

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
