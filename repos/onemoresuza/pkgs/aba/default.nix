{
  fetchFromSourcehut,
  just,
  lib,
  rustPlatform,
  scdoc,
}: let
  version = "0.6.2";
in
  rustPlatform.buildRustPackage {
    pname = "aba";
    inherit version;

    src = fetchFromSourcehut {
      owner = "~onemoresuza";
      repo = "aba";
      rev = version;
      hash = "sha256-kijWQOFezPBpSUEt/PQ3hGoQCJcsTYJS28qRDOZmqno=";
      domain = "sr.ht";
    };

    cargoSha256 = "sha256-Wuwffc9oCZ3OqUXHfFYCyTc3SQXWe/r9CfAksB0/Hxw=";

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
      license = lib.licenses.mit;
      platform = lib.platforms.unix;
      mainProgram = "aba";
    };
  }
