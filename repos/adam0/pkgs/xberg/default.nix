{
  # keep-sorted start
  fetchFromGitHub,
  fetchurl,
  lib,
  libheif,
  pkg-config,
  rustPlatform,
  # keep-sorted end
}: let
  # Match the test_documents submodule revision pinned by the release.
  testDocuments = fetchFromGitHub {
    owner = "xberg-io";
    repo = "test_documents";
    rev = "4139c3b5ad3cbcfca23e181a8b188062ce5f930e";
    hash = "sha256-f4yiBNkRi1tHBYTbP8KWQEvaKSrY9EAELWQj0hLMH1Y=";
  };

  # Hydrate the binary fixtures from the release's content-addressed corpus manifest.
  docxFixture = fetchurl {
    url = "https://storage.googleapis.com/xberg-test-documents/objects/f4be87905250fc9792ed5a1910529a8998588fc06308e743744acfeddd010679";
    hash = "sha256-9L6HkFJQ/JeS7VoZEFKaiZhYj8BjCOdDdErP7d0BBnk=";
  };
  pdfFixture = fetchurl {
    url = "https://storage.googleapis.com/xberg-test-documents/objects/44af20f038f0e11d67f3aebe2f683276a73d01e8167596bd691d1b047ed7012f";
    hash = "sha256-RK8g8Djw4R1n866+L2gydqc9AegWdZa9aR0bBH7XAS8=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "xberg";
    version = "1.3.6";

    src = fetchFromGitHub {
      owner = "xberg-io";
      repo = "xberg";
      tag = "v${finalAttrs.version}";
      hash = "sha256-Ry1SdFObIAHVS5rxe/NmeU4JRYEzemQ5l9hWZ7Eb+YQ=";
    };

    # Align upstream tests with the selected features and current config schema.
    patches = [
      # keep-sorted start
      ./current-chunking-config-test.patch
      ./feature-gated-cli-help-tests.patch
      ./nonnegative-batch-timing-test.patch
      ./profile-aware-server-help-tests.patch
      # keep-sorted end
    ];

    # Release archives omit submodules required by the integration tests.
    postPatch = ''
      cp -r ${testDocuments}/. test_documents/
      chmod -R u+w test_documents
      mkdir -p test_documents/docx test_documents/pdf
      cp ${docxFixture} test_documents/docx/word_tables.docx
      cp ${pdfFixture} test_documents/pdf/pdfa_001.pdf
    '';

    cargoHash = "sha256-q3Vo8roPPOiL9OKi/JogNwjKPl9UgLxIDpfZ9l9cvig=";
    cargoBuildFlags = ["--package" "xberg-cli"];
    # Report failures across all test targets in one remote build.
    cargoTestFlags = ["--no-fail-fast" "--package" "xberg-cli"];

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
