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
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "akitaonrails";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-2T1QuihBJxPIR94Mu2YMf/Qds+o9bES6cpm00thOKKY=";
  };

  cargoHash = "sha256-EhXDjKxYG5qEbQst7sirVDmoOl2IKCciEbszcCrBV/A=";

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
