{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "cc-safety-net";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "kenryu42";
    repo = "claude-code-safety-net";
    rev = "v${version}";
    hash = "sha256-pdcKPrma0L13tMrU6bjuMSHwvqgdIQ6nw66G1rbNRkI=";
  };

  dependencyHash = null;

  meta = {
    description = "OpenCode plugin that blocks destructive git and filesystem commands";
    homepage = "https://github.com/kenryu42/claude-code-safety-net";
    license = lib.licenses.mit;
  };
}
