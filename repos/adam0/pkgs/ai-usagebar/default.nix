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
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "akitaonrails";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-QAgly1U8cZ5mVEWTlQXOxELxERlH2Ocw0Ud8aBsogsw=";
  };

  cargoHash = "sha256-PfUOlXovUItOE1nTXZN0Hsu0l/7qTyHWtw7UZroa3Jk=";

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
