{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule rec {
  inherit (sources.axiom-syslog-proxy) pname version src;
  vendorHash = "sha256-tueoQF9+G8ovAe1tIjZllks6zTAVp7La+A7vpdu5hzU=";

  meta = {
    changelog = "https://github.com/axiomhq/axiom-syslog-proxy/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Syslog push interface to Axiom";
    homepage = "https://github.com/axiomhq/axiom-syslog-proxy";
    license = lib.licenses.mit;
    mainProgram = "axiom-syslog-proxy";
  };
}
