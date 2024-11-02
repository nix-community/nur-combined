{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule {
  inherit (sources.axiom-syslog-proxy) pname version src;
  vendorHash = "sha256-2tv2j8XZj5ngrQuD+XjGtfbsf4k0rr4ZiUyFZs6RHfo=";

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Syslog push interface to Axiom";
    homepage = "https://github.com/axiomhq/axiom-syslog-proxy";
    license = lib.licenses.mit;
  };
}
