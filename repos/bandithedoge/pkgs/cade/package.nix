{
  sources,

  lib,
  rustPlatform,

  pkg-config,
  sqlite,
}:
rustPlatform.buildRustPackage {
  inherit (sources.cade) pname src;
  version = sources.cade.date;
  cargoLock = sources.cade.cargoLock."Cargo.lock";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ sqlite ];

  meta = {
    description = "Intelligent, cascading environment manager";
    homepage = "https://github.com/manic-systems/cade";
    license = lib.licenses.eupl12;
    platforms = lib.platforms.unix;
    mainProgram = "cade";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
