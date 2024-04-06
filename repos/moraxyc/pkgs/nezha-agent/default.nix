{
  buildGoModule,
  lib,
  sources,
  system ? builtins.currentSystem,
  ...
} @ args:
buildGoModule rec {
  pname = "nezha-agent";
  inherit (sources.nezha-agent) version src;
  vendorHash = "sha256-ZlheRFgl3vsUXVx8PKZQ59kme2NC31OQAL6EaNhbf70=";
  CGO_ENABLED = 0;

  ldflags = [
    "-s -w"
    "-X main.version=${version}"
    "-X main.arch=${system}"
  ];

  checkPhase = ''
    runHook preCheck
    export GOFLAGS=''${GOFLAGS//-trimpath/}
    rm ./pkg/monitor/myip_test.go
    for pkg in $(getGoDirs test); do
      buildGoDir test "$pkg"
    done
    runHook postCheck
  '';

  meta = with lib; {
    description = "Agent of Nezha Monitoring";
    homepage = "https://github.com/nezhahq/agent";
    license = licenses.asl20;
  };
}
