{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "morph-fast-apply";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "JRedeker";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-I24qrBRPLhF1Oaa1TjvKE4AcEpuTLxQjyXqD01zrxS4=";
  };

  dependencyHash = "sha256-pOdO7KHWbNIayPlUz1ydVklMTqROL/evADFw9OYRT7U=";

  postInstall = ''
    cd "$out"
    bun build index.ts --outdir dist --target node
    substituteInPlace package.json --replace-fail '"main": "index.ts"' '"main": "dist/index.js"'
  '';

  meta = {
    description = "OpenCode plugin for Morph Fast Apply - 10x faster code editing";
    homepage = "https://github.com/JRedeker/opencode-morph-fast-apply";
    license = lib.licenses.mit;
  };
}
