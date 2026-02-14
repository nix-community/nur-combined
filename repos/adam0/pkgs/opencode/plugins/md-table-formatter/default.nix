{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "md-table-formatter";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "franlol";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-YkS2pohLT9s+V+I0sd+RfNtcetZLMC6o9A2WXeZK+S8=";
  };

  dependencyHash = null;

  postInstall = ''
    cd "$out"
    bun build index.ts --outdir dist --target node
  '';

  meta = {
    description = "OpenCode plugin for markdown table formatting with concealment mode support";
    homepage = "https://github.com/franlol/opencode-md-table-formatter";
    license = lib.licenses.mit;
  };
}
