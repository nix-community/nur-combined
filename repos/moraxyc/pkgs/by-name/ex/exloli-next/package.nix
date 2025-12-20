{
  lib,
  rustPlatform,
  pkg-config,
  openssl,
  sqlite,
  sources,
}:

rustPlatform.buildRustPackage {
  pname = "exloli-next";

  inherit (sources.exloli-next) version src;

  cargoHash = "sha256-weV2D9253qrqeF7lN8ucJdMz3kgh/IjCAZWI6EI4ytw=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    sqlite
  ];

  # need db.text.json
  doCheck = false;

  meta = {
    homepage = "https://github.com/lolishinshi/exloli-next";
    license = lib.licenses.mit;
    mainProgram = "exloli";
  };
}
