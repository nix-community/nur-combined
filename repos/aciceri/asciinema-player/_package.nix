{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  rustPlatform,
  lld,
  wasm-bindgen-cli_0_2_92,
  cargo,
  makeWrapper,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "asciinema-player";
  version = "3.11.1";

  src = fetchFromGitHub {
    owner = "asciinema";
    repo = "asciinema-player";
    rev = "v3.11.1";
    hash = "sha256-PfBxTHGzLD0xMvqc7to1w6oaT6WH7b5A8D5jD6p/3Rc=";
  };

  npmDepsHash = "sha256-av2yXbZtdwCQD1PogSL1G/OC4B+YuyhDaOLqU/9nNwM=";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    cargoRoot = "src/vt";
    hash = "sha256-RHBFYhonGsYwJp7+pJJ2Gnz7QM2JFECP2A+YxFVVyIE=";
  };

  cargoRoot = "src/vt";

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    lld
    wasm-bindgen-cli_0_2_92
    makeWrapper
  ];

  env = {
    CARGO_BIN = lib.getExe cargo;
    WASM_BINDGEN_BIN = lib.getExe wasm-bindgen-cli_0_2_92;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/asciinema-player
    cp -r dist/* $out/lib/asciinema-player/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A web player for terminal session recordings";
    homepage = "https://github.com/asciinema/asciinema-player";
    license = licenses.asl20;
    maintainers = [ maintainers.aciceri ];
    platforms = platforms.all;
  };
}
