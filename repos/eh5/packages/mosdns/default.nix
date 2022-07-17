{ lib
, runCommand
, buildGo118Module
, fetchFromGitHub
, makeBinaryWrapper
, symlinkJoin
, v2ray-geoip
, v2ray-domain-list-community
, sources
}:
let
  assetsDrv = symlinkJoin {
    name = "mosdns-assets";
    paths = [
      "${v2ray-geoip}/share/v2ray"
      "${v2ray-domain-list-community}/share/v2ray"
    ];
  };
  mosdns = buildGo118Module {
    pname = "mosdns";
    inherit (sources.mosdns) version src;
    vendorSha256 = "sha256-C7dPFVUhdnrC6itNSdFJsKHDSv28ZoRk5ZjUyzRyRNE=";
    doCheck = false;

    buildPhase = ''
      buildFlagsArray=(-v -p $NIX_BUILD_CORES -ldflags="-s -w")
      runHook preBuild
      go build "''${buildFlagsArray[@]}" -o mosdns ./
      runHook postBuild
    '';

    installPhase = ''
      install -Dm755 mosdns -t $out/bin
    '';

    meta = with lib; {
      description = "A DNS proxy server";
      homepage = "https://github.com/IrineSistiana/mosdns";
      license = licenses.gpl3;
    };
  };
in
runCommand mosdns.name
{
  inherit (mosdns) version meta pname;
  nativeBuildInputs = [ makeBinaryWrapper ];
} ''
  makeWrapper ${mosdns}/bin/mosdns "$out/bin/mosdns" --chdir ${assetsDrv}
''
