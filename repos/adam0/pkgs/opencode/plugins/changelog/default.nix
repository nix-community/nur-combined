{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "changelog";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "tobwen";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-DiFqIMSXB4ba44x/7H9k/nH2YBWUy+Kt98gpo5Q/iX8=";
  };

  dependencyHash = null;

  postInstall = ''
    cd "$out"
    bun build src/index.ts --outdir dist --target node --format esm
  '';

  meta = {
    description = "OpenCode plugin that adds a /changelog command";
    homepage = "https://github.com/tobwen/opencode-changelog";
    license = lib.licenses.mit;
  };
}
