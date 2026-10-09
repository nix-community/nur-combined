{ lib
, fetchFromGitHub
, rustPlatform
}:
let
  pname = "wtfi2";
  version = "0.6.0";
  owner = "kanywst";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub rec {
    inherit owner;
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-jNAx77pRhzoYHbB//2FS1EhR5v47Ueh8JDXKC+AHVIg=";
  };

  cargoHash = "sha256-1IBlpygfsVvkQpp4/Gi5M/Cb8gHakhEwaBgVvdXEQ3U=";

  # There is no tests
  doCheck = false;

  meta = {
    description = "What The F*ck Internet — a live, visual network path diagnostic that pinpoints exactly where your connection dies.";
    homepage = "https://github.com/kanywst/wtfi2";
    changelog = "https://github.com/kanywst/wtfi2/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "wtfi";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
  };
}
