{
  lib,
  sources,
  buildGoModule,
  xz,
}:
buildGoModule rec {
  inherit (sources.payload-dumper-go) pname version src;
  vendorHash = "sha256-CqIZFMDN/kK9bT7b/32yQ9NJAQnkI8gZUMKa6MJCaec=";

  buildInputs = [ xz ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Android OTA payload dumper written in Go";
    homepage = "https://github.com/ssut/payload-dumper-go";
    license = lib.licenses.asl20;
  };
}
