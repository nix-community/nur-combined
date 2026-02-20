{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "openslimedit";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "ASidorenkoCode";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-xNclhUylIXXKXx5zhlVQcUsY55KZaB2jMUSpYNg9nCI=";
  };

  dependencyHash = null;

  postInstall = ''
    cd "$out"
    bun build src/index.ts --outdir dist --target node --format esm
    substituteInPlace package.json --replace-fail '"./src/index.ts"' '"./index.js"'
    substituteInPlace package.json --replace-fail '"version": "${version}",' '"version": "${version}",\n  "main": "./index.js",'
    printf '%s\n' 'export { default } from "./dist/index.js"' > index.js
  '';

  meta = {
    description = "OpenCode plugin that reduces token usage by compressing tool metadata";
    homepage = "https://github.com/ASidorenkoCode/openslimedit";
    license = lib.licenses.mit;
  };
}
