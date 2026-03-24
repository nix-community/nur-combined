{ sources, pkgs, ... }:
pkgs.buildGoModule rec {
  name = "prometheus-hue-exporter";
  src = sources.hue_exporter;
  vendorHash = "sha256-xPAXqFe2DdN4v+Bmg6Q1Qa/os3X0J/gsIjIOPkiTBfY=";
  proxyVendor = true;
  checkFlags = [ "-short" ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    install -Dm644 hue_metrics.json $out/share/hue_metrics.json
    dir="$GOPATH/bin"
    [ -e "$dir" ] && cp -r $dir $out
    runHook postInstall
  '';
}
