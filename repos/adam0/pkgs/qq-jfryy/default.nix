{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  lib,
  # keep-sorted end
}:
buildGoModule rec {
  pname = "qq-jfryy";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "JFryy";
    repo = "qq";
    rev = "v${version}";
    hash = "sha256-RW4k6E4/z0MMya8pgeoNDvGfnlfr8WPc+ETAmC+XKww=";
  };

  vendorHash = "sha256-2qBVrMddlB7Zb1w27b2bwO/FuXZpKzG8OFBRlrTkrGE=";

  meta = {
    # keep-sorted start
    description = "jq, but with many interoperable configuration format transcodings and interactive querying";
    homepage = "https://github.com/JFryy/qq";
    license = lib.licenses.mit;
    mainProgram = "qq";
    platforms = lib.platforms.unix;
    # keep-sorted end
  };
}
