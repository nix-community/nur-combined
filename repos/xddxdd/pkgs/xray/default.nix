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
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "XTLS";
    repo = "Xray-core";
    rev = "v${version}";
    sha256 = "sha256-ZZiZ3sX5R+E4v4WUBQM1b0Zc1dudppmzzsci4TLFbCc=";
  };

  vendorSha256 = "sha256-urpt9JCO7kT3iwyYGt4FOilkS2TFefTqoPZ9ksc8S70=";

  assets = {
    # MIT licensed
    "geoip.dat" =
      let
        geoipRev = "202112230031";
        geoipSha256 = "1mjp9y2926g6y0qqsaq389cs2cfvs4yysybmyc5ykrh82hidj1yh";
      in
      fetchurl {
        url = "https://github.com/v2fly/geoip/releases/download/${geoipRev}/geoip.dat";
        sha256 = geoipSha256;
      };

    # MIT licensed
    "private.dat" =
      let
        geoipRev = "202112230031";
        geoipSha256 = "1s60xrnii6rmi6ca2sbhlnx0x6cmzfxd7g2lbvz0kchfxfnyhlfw";
      in
      fetchurl {
        url = "https://github.com/v2fly/geoip/releases/download/${geoipRev}/private.dat";
        sha256 = geoipSha256;
      };

    # MIT licensed
    "geosite.dat" =
      let
        geositeRev = "20211218145115";
        geositeSha256 = "1id5ai63fpj06rj50b4lnn4hl7ik34hv3ys1886z2cpxg406nynf";
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
