{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin rec {
  pname = "faster-piper.yazi";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "alberti42";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Rr1JYSDi4wWQu5DTMu3i2NfrXNG46idXKYJtRTuD38c=";
  };

  meta = {
    description = "Pipe any shell command as a cached previewer.";
    homepage = "https://github.com/alberti42/faster-piper.yazi";
    license = lib.licenses.mit;
  };
}
