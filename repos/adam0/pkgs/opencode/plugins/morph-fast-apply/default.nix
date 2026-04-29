{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "morph-fast-apply";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "JRedeker";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-XjZDwSPidAgNZHyIh6VjOiuDrjOeTFdC5fmTK0UZVm8=";
  };

  dependencyHash = "sha256-G4g5vBV8/4LRU+8aa4h2vzvuV17e+Dole07poz6r0Hc=";

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
