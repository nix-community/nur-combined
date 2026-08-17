{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "faster-piper.yazi";
  version = "1.1.1-unstable-2026-08-16";

  src = fetchFromGitHub {
    owner = "alberti42";
    repo = pname;
    rev = "bb90261ce3952762b0de2d5720ea176615c1bbd9";
    hash = "sha256-a7/KTIoIU9idxhYmYFsp6/ezmiBK/mEYfEz9zqZZiEU=";
  };

  meta = {
    # keep-sorted start
    description = "Pipe any shell command as a cached previewer";
    homepage = "https://github.com/alberti42/faster-piper.yazi";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
