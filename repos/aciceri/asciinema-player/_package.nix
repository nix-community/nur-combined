{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  rustPlatform,
  lld,
  cargo,
  buildWasmBindgenCli,
  fetchCrate,
  makeWrapper,
  writeShellScript,
  nix-update,
}:
let
  wasm-bindgen-cli_0_2_106 = buildWasmBindgenCli rec {
    src = fetchCrate {
      pname = "wasm-bindgen-cli";
      version = "0.2.106";
      hash = "sha256-M6WuGl7EruNopHZbqBpucu4RWz44/MSdv6f0zkYw+44=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit src;
      inherit (src) pname version;
      hash = "sha256-ElDatyOwdKwHg3bNH/1pcxKI7LXkhsotlDPQjiLHBwA=";
    };
  };

in
buildNpmPackage rec {
  pname = "asciinema-player";
  version = "3.15.0";

  src = fetchFromGitHub {
    owner = "asciinema";
    repo = "asciinema-player";
    rev = "v3.15.0";
    hash = "sha256-rfmRvQGGK3SRRrBGkXgMkbDzbgWRy0PDMsrfiudoqmE=";
  };

  npmDepsHash = "sha256-CqiHg+cvOqjMLfIyY6BrHSmW4I/H2CEIDT/tpFoGr5g=";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    cargoRoot = "src/vt";
    hash = "sha256-anyrCXM84CfbTxNzaQSWbLY42rKM0KESwibvN1csfao=";
  };

  cargoRoot = "src/vt";

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    lld
    wasm-bindgen-cli_0_2_106
    makeWrapper
  ];

  env = {
    CARGO_BIN = lib.getExe cargo;
    WASM_BINDGEN_BIN = lib.getExe wasm-bindgen-cli_0_2_106;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/asciinema-player
    cp -r dist/* $out/lib/asciinema-player/

    runHook postInstall
  '';

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake asciinema-player";

  meta = with lib; {
    description = "A web player for terminal session recordings";
    homepage = "https://github.com/asciinema/asciinema-player";
    license = licenses.asl20;
    maintainers = [ maintainers.aciceri ];
    platforms = platforms.all;
  };
}
