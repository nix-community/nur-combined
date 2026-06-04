{
  sources,
  version,
  hash,
  lib,
  buildGoModule,
}:
buildGoModule {
  inherit (sources) pname src;
  inherit version;
  vendorHash = hash;

  meta = {
    description = "Lightweight local proxy server that protects TLS connections over TCP";
    homepage = "https://github.com/moi-si/lumine";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "lumine";
  };
}
