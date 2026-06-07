{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "morph-fast-apply";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "JRedeker";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-tz4T03Zw5HJUwLeRf58qjsVr+LKXauY1C8QWJFm9+rI=";
  };

  dependencyHash = "sha256-JdWixTkCZqmpAvmrIOw2ABD0WImYGJgP/0MJuvCtMfs=";

  buildCommand = "bun build index.ts --outdir dist --target node";

  postInstall = ''
    substituteInPlace package.json --replace-fail '"main": "index.ts"' '"main": "dist/index.js"'
  '';

  meta = {
    # keep-sorted start
    description = "OpenCode plugin for Morph Fast Apply - 10x faster code editing with lazy edit markers.";
    homepage = "https://github.com/JRedeker/opencode-morph-fast-apply";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
