{
  # keep-sorted start
  fetchFromCodeberg,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
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

  buildCommand = "bun build src/index.ts --outdir dist --target node --format esm";

  meta = {
    # keep-sorted start
    description = "OpenCode plugin that strips emojis from agent outputs in Opencode";
    homepage = "https://codeberg.org/bastiangx/opencode-unmoji";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
