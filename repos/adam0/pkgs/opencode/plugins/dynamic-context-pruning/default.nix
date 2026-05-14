{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  typescript,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "dynamic-context-pruning";
  version = "3.1.12";

  src = fetchFromGitHub {
    owner = "Opencode-DCP";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-dtLb7fU990LvdSv5em1OkiyUgSvr1Tgt+WqHNw2mRPA=";
  };

  dependencyHash = "sha256-+kWxZBoIM+Q5wr7/S89/fexkqT98fObXmbCDm2tp3Uo=";

  nativeBuildInputs = [typescript];

  buildCommand = "tsc -p tsconfig.json";

  meta = {
    # keep-sorted start
    description = "OpenCode plugin for dynamic context pruning and token usage optimization";
    homepage = "https://github.com/Opencode-DCP/opencode-dynamic-context-pruning";
    license = lib.licenses.agpl3Plus;
    # keep-sorted end
  };
}
