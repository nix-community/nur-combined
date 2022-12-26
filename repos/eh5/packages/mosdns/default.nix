{ lib
, runCommand
, buildGoModule
, fetchFromGitHub
, makeBinaryWrapper
, symlinkJoin
, v2ray-geoip
, v2ray-domain-list-community
, assetsDir ? null
, sources
}:
let
  assetsDrv =
    if assetsDir != null then assetsDir else
    symlinkJoin {
      name = "mosdns-assets";
      paths = [
        "${v2ray-geoip}/share/v2ray"
        "${v2ray-domain-list-community}/share/v2ray"
      ];
    };
  mosdns = buildGoModule rec {
    pname = "mosdns";
    version = "v4.5.3";
    src = fetchFromGitHub ({
      owner = "IrineSistiana";
      repo = "mosdns";
      rev = version;
      fetchSubmodules = false;
      sha256 = "sha256-pWzEoy2sbee2j4WocUanSrTf6S179PCJE4qZ/81BBe0=";
    });
    vendorSha256 = "sha256-yFXxYAX0yvuDtkN2/WFY9SL3KhAnbemm4ZzkYz+8BeI=";
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
  passthru = {
    original = mosdns;
  };
} ''
  makeWrapper ${mosdns}/bin/mosdns "$out/bin/mosdns" --chdir ${assetsDrv}
''
