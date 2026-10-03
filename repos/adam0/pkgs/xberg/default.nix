{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  libheif,
  pkg-config,
  rustPlatform,
  # keep-sorted end
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xberg";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "xberg-io";
    repo = "xberg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+nkWIgrLZ7vx4wSOA9We/72cbw7S06wJKPxytAcpQ7s=";
  };

  cargoHash = "sha256-70Tm9T5gr9D1MmmhQkwlvfGRlvZCDYL92aYacQXj+fU=";
  cargoBuildFlags = ["--package" "xberg-cli"];
  cargoTestFlags = ["--package" "xberg-cli"];

  # Isolate process-wide tracing state and ambient log filters during tests.
  checkFlags = ["--test-threads=1"];
  preCheck = ''
    unset RUST_LOG
  '';

  nativeBuildInputs = [pkg-config];
  buildInputs = [libheif];

  # Enable all format parsers without OCR, model runtimes, or PDFium.
  buildNoDefaultFeatures = true;
  buildFeatures = [
    # keep-sorted start
    "core-cli"
    "formats"
    # Format tests inspect this subset flag even when all formats are enabled.
    "formats-no-heic"
    # keep-sorted end
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$TMPDIR"
    $out/bin/xberg --version
    printf '%s\n' '<html><body>DocumentExtractionSentinel</body></html>' > sample.html
    $out/bin/xberg extract sample.html --content-format plain | grep -F DocumentExtractionSentinel
    runHook postInstallCheck
  '';

  meta = {
    # keep-sorted start
    description = "Document text extractor without OCR or ML runtimes";
    homepage = "https://xberg.io";
    license = lib.licenses.mit;
    mainProgram = "xberg";
    platforms = lib.platforms.unix;
    # keep-sorted end
  };
})
