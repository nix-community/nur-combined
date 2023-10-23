{
  fetchFromSourcehut,
  just,
  lib,
  rustPlatform,
  scdoc,
}: let
  version = "0.5.1";
in
  rustPlatform.buildRustPackage {
    pname = "aba";
    inherit version;

    src = fetchFromSourcehut {
      owner = "~onemoresuza";
      repo = "aba";
      rev = version;
      hash = "sha256-63FdS/ouU52NdpS1+Mx0of+emXI9UodZnxEiXhSckcE=";
      domain = "sr.ht";
    };

    cargoSha256 = "sha256-4a1LXsz8jnHoCoPYaLD9hHLyzDoD4DdGeRQbv1mwnyA=";

    nativeBuildInputs = [
      just
      scdoc
    ];

    dontUseJustBuild = true;
    dontUseJustCheck = true;
    dontUseJustInstall = true;

    postInstall = ''
      just --set prefix $out install-doc
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
