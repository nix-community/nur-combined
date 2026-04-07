{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "quotes";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "aerovato";
    repo = "opencode-${pname}-plugin";
    rev = "55bce2d5c3f4b12c3b0b4dffdc3deb7e96b52c47";
    hash = "sha256-TWOxOiF/zXFK4/wrytuRwdM08YveANc2zM33Bx3NbaE=";
  };

  dependencyHash = "sha256-QFxwoEhensQpiZHDR6D2+nzDz4WRN6XNV3A5yaXNZGE=";

  postInstall = ''
    cd "$out"
    cp ${./build.ts} ./build.ts
    bun run build.ts
    substituteInPlace package.json \
      --replace-fail '"version": "${version}",' '"version": "${version}",\n  "main": "./index.js",'
    printf '%s\n' 'export { default } from "./dist/tui.js"' > index.js
  '';

  meta = {
    description = "OpenCode plugin that replaces the default home tips with motivational quotes";
    homepage = "https://github.com/aerovato/opencode-quotes-plugin";
    license = lib.licenses.mit;
  };
}
