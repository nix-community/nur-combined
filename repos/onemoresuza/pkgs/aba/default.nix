{
  fetchFromSourcehut,
  just,
  lib,
  rustPlatform,
  scdoc,
}: let
  version = "0.5.0";
in
  rustPlatform.buildRustPackage {
    pname = "aba";
    inherit version;

    src = fetchFromSourcehut {
      owner = "~onemoresuza";
      repo = "aba";
      rev = version;
      hash = "sha256-C9AQS5rs6MuOaL28WFWMSacV6Fk/s3X/UpibGRrbNDk=";
      domain = "sr.ht";
    };

    cargoSha256 = "sha256-WsenvOSjO0LdiXxFxltkfdJj7Yg7dIKXTdrQkCp6mYo=";

    nativeBuildInputs = [
      just
      scdoc
    ];

    postPatch = ''
      substituteInPlace justfile  \
        --replace "prefix := \"/usr/local\"" "prefix := \"$out\"" \
    '';

    buildPhase = ''
      runHook preBuild
      just build
      runHook postBuild
    '';

    meta = {
      description = "An address book for aerc";
      homepage = "https://sr.ht/~onemoresuza/aba/";
      changelog = "https://git.sr.ht/~onemoresuza/aba/tree/main/item/CHANGELOG.md";
      license = lib.licenses.mit;
      platform = lib.platforms.unix;
      mainProgram = "aba";
    };
  }
