{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "tokenscope";
  version = "1.5.2";

  src = "${
    fetchFromGitHub {
      owner = "ramtinJ95";
      repo = "opencode-${pname}";
      rev = "v${version}";
      hash = "sha256-9VyeRo81DSmV9N/Xzm+hWnL0kbcAA9wWOYGwVmIC8o8=";
    }
  }/plugin";

  dependencyHash = "sha256-m06xVaICuqckzfjBSBz07J1XWvL7iRhum0aQXJ2pTl8=";

  postInstall = ''
    cd "$out"
    bun build tokenscope.ts --outdir dist --target node
  '';

  meta = {
    description = "OpenCode plugin for token usage analysis and cost tracking";
    homepage = "https://github.com/ramtinJ95/opencode-tokenscope";
    license = lib.licenses.mit;
  };
}
