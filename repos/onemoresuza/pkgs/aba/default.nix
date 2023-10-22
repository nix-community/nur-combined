{
  fetchFromSourcehut,
  just,
  lib,
  rustPlatform,
  scdoc,
}: let
  version = "0.3.0";
in
  rustPlatform.buildRustPackage {
    pname = "aba";
    inherit version;

    src = fetchFromSourcehut {
      owner = "~onemoresuza";
      repo = "aba";
      rev = version;
      hash = "sha256-1HJcbHhBi4YrL4Q6a3bG1NnySLbN7w3aRl539fQ4vqg=";
      domain = "sr.ht";
    };

    cargoSha256 = "sha256-IJFtlLiT15T+RZgYVg0Dt2ysWoIM1Z6dLxNZELp6+0s=";

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
      just bin
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
