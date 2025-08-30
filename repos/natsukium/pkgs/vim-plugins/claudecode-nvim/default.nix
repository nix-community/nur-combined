{
  source,
  lib,
  buildVimPlugin,
}:

buildVimPlugin {
  inherit (source) pname src;
  version = "unstable-${source.date}";

  dontBuild = true;

  meta = with lib; {
    description = "Claude Code Neovim IDE Extension";
    homepage = "https://github.com/coder/claudecode.nvim";
    license = licenses.mit;
  };
}
