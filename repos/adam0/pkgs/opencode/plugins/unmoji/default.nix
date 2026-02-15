{
  lib,
  fetchFromCodeberg,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "unmoji";
  version = "0.3.12";

  src = fetchFromCodeberg {
    owner = "bastiangx";
    repo = "opencode-${pname}";
    rev = version;
    hash = "sha256-yL+e83vEEmtElRVdC9uIweFQ4CqtwqLUtitYRi7ncNc=";
  };

  dependencyHash = "sha256-mx5l95k3saYu7WYF7YDGziFZX9+YzZwk+UrogK1xlcQ=";

  postInstall = ''
    cd "$out"
    bun build src/index.ts --outdir dist --target node --format esm
  '';

  meta = with lib; {
    description = "OpenCode plugin that removes or replaces emojis";
    homepage = "https://codeberg.org/bastiangx/opencode-unmoji";
    license = licenses.mit;
  };
}
