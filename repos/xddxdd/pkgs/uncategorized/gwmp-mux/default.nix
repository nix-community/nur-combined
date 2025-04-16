{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  inherit (sources.gwmp-mux) pname version src;

  cargoHash = "sha256-0PsG81CuQcpzjJR3lhtCjE4tlD8tpyuzqIaRVS8U8cI=";
  useFetchCargoVendor = true;

  meta = {
    changelog = "https://github.com/helium/gwmp-mux/releases/tag/v${version}";
    mainProgram = "gwmp-mux";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Multiplexer for Semtech's GWMP over UDP";
    homepage = "https://github.com/helium/gwmp-mux";
    license = lib.licenses.asl20;
  };
}
