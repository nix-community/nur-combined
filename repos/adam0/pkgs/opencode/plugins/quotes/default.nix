{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "quotes";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "aerovato";
    repo = "opencode-${pname}-plugin";
    rev = "v${version}";
    hash = "sha256-0h5B9GnBV1uBKvfk/AVryciZUhRMQSgVOATm9cMHvh0=";
  };

  dependencyHash = "sha256-QFxwoEhensQpiZHDR6D2+nzDz4WRN6XNV3A5yaXNZGE=";

  postInstall = ''
    cd "$out"
    cp ${./build.ts} ./build.ts
    bun run build.ts
    substituteInPlace package.json \
      --replace-fail '"type": "module",' '"type": "module",\n  "main": "./index.js",'
    printf '%s\n' 'export { default } from "./dist/tui.js"' > index.js
  '';

  meta = {
    # keep-sorted start
    description = "OpenCode plugin that replaces the default home tips with motivational quotes";
    homepage = "https://github.com/aerovato/opencode-quotes-plugin";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
