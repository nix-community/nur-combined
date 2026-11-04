{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  lib,
  # keep-sorted end
}:
buildGoModule rec {
  pname = "qq-jfryy";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "JFryy";
    repo = "qq";
    rev = "v${version}";
    hash = "sha256-q3DZFAGwg/mBrokwVH58v074ifdh0WOOHYiqP3kwFhc=";
  };

  vendorHash = "sha256-KVqWgcC0NBGyTkDBl+whkk9c5gETrk71FR8NkUXo7OM=";

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
