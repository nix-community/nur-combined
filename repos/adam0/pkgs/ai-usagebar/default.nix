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
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "akitaonrails";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-K1Ch+13kFXzNZh5vm/fKMiQrCKFuPMFoIXCpK6DkHx8=";
  };

  cargoHash = "sha256-MoFkNt78SyzgZJwrI3+WTlimelK6AXhKSdTQTXMLH0o=";

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
