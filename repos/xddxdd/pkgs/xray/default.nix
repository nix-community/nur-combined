{ lib
, fetchFromGitHub
, sources
, linkFarm
, buildGoModule
, runCommand
, makeWrapper
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
