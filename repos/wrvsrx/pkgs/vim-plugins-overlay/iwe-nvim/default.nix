{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin {
  pname = "iwe-nvim";
  version = "0-unstable-2026-05-17";

  src = fetchFromGitHub {
    owner = "iwe-org";
    repo = "iwe.nvim";
    rev = "e6efe64c308e2a2708c1ae9c82749f46b3fe45e0";
    hash = "sha256-/ggxBpwnnXC9GC9usw8KjacgWLlwlwdyOzZN1m2z+zY=";
  };
}
