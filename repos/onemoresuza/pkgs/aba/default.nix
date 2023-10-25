{
  fetchFromSourcehut,
  just,
  lib,
  rustPlatform,
  scdoc,
}: let
  version = "0.7.0";
in
  rustPlatform.buildRustPackage {
    pname = "aba";
    inherit version;

    src = fetchFromSourcehut {
      owner = "~onemoresuza";
      repo = "aba";
      rev = version;
      hash = "sha256-YPE5HYa90BcNy5jdYbzkT81KavJcbSeGrsWRILnIiEE=";
      domain = "sr.ht";
    };

    cargoSha256 = "sha256-wzI+UMcVeFQNFlWDkyxk8tjpU7beNRKoPYbid8b15/Q=";

    nativeBuildInputs = [
      just
      scdoc
    ];

    dontUseJustBuild = true;
    dontUseJustCheck = true;
    dontUseJustInstall = true;

    postInstall = ''
      just --set PREFIX $out install-doc
    '';

    meta = {
      description = "An address book for aerc";
      homepage = "https://sr.ht/~onemoresuza/aba/";
      changelog = "https://git.sr.ht/~onemoresuza/aba/tree/main/item/CHANGELOG.md";
      license = lib.licenses.isc;
      platform = lib.platforms.unix;
      mainProgram = "aba";
    };
  }
