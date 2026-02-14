{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "morph-fast-apply";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "JRedeker";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-0Ex1OnwhkZB9eZz2ZAK8pxGUVGIkIiaaiDhrkG29rN0=";
  };

  dependencyHash = "sha256-pOdO7KHWbNIayPlUz1ydVklMTqROL/evADFw9OYRT7U=";

  meta = {
    description = "OpenCode plugin for Morph Fast Apply - 10x faster code editing";
    homepage = "https://github.com/JRedeker/opencode-morph-fast-apply";
    license = lib.licenses.mit;
  };
}
