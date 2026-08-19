{
  # keep-sorted start
  fetchFromGitHub,
  gnutar,
  lib,
  rustPlatform,
  # keep-sorted end
}:
rustPlatform.buildRustPackage rec {
  pname = "ai-usagebar";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "akitaonrails";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-f2AmK35Eds+kka6NQp+Mo6Acz7lnUOPLZxRhh+Sl/bE=";
  };

  cargoHash = "sha256-JSv9NBGMNm3npyDdH8MlTLoNF+xV+SmQSC2SgXpcrxQ=";

  postPatch = ''
    substituteInPlace src/claude_desktop/app.rs \
      --replace-fail 'Command::new("/usr/bin/tar")' 'Command::new("${gnutar}/bin/tar")'
  '';

  meta = with lib; {
    # keep-sorted start
    description = "Usage bar for AI coding assistants";
    homepage = "https://github.com/akitaonrails/ai-usagebar";
    license = licenses.mit;
    mainProgram = pname;
    platforms = platforms.unix;
    # keep-sorted end
  };
}
