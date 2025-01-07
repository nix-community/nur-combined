{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.gwmp-mux) pname version src;

  cargoHash = "sha256-MvnYUD0eF3CJXVqLGeSxjjEbCv9B6/KoDtZpvE7hY8E=";

  meta = {
    mainProgram = "gwmp-mux";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Multiplexer for Semtech's GWMP over UDP";
    homepage = "https://github.com/helium/gwmp-mux";
    license = lib.licenses.asl20;
  };
}
