{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule {
  inherit (sources.axiom-syslog-proxy) pname version src;
  vendorHash = "sha256-tueoQF9+G8ovAe1tIjZllks6zTAVp7La+A7vpdu5hzU=";

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Syslog push interface to Axiom";
    homepage = "https://github.com/axiomhq/axiom-syslog-proxy";
    license = lib.licenses.mit;
    mainProgram = "axiom-syslog-proxy";
  };
}
