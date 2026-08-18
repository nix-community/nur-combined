{
  lib,
  rustPlatform,
  fetchFromGitHub,
  git,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "git-hunk";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "nexxeln";
    repo = "git-hunk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VMEoqwn1oW9ehbBawCsy8B/r7Bfm9rKGUMPB8hynNvo=";
  };

  cargoHash = "sha256-iiqlFZTAlFF6jy5m8jMcqLcRvNLkPdRlK/XoQucceoQ=";

  nativeCheckInputs = [ git ];

  meta = {
    description = "Non-interactive hunk staging for AI agents";
    homepage = "https://github.com/nexxeln/git-hunk";
    changelog = "https://github.com/nexxeln/git-hunk/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "git-hunk";
  };
})
