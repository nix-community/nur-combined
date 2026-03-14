{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin rec {
  pname = "faster-piper.yazi";
  version = "unstable-2026-02-02";

  src = fetchFromGitHub {
    owner = "alberti42";
    repo = pname;
    rev = "8b794bfa3bc9c780e3f03b6f5a0ccde7744e54bb";
    hash = "sha256-m6ZiwA36lcdZORK3KIz4Xq3bs7mmtC6j62B/+BuDGAQ=";
  };

  meta = {
    description = "Pipe any shell command as a cached previewer.";
    homepage = "https://github.com/alberti42/faster-piper.yazi";
    license = lib.licenses.mit;
  };
}
