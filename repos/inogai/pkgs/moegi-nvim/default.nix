{
  lib,
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "moegi-nvim";
  version = "0.1.0-git.a7c11f";

  src = fetchFromGitHub {
    owner = "inogai";
    repo = "moegi.nvim";
    rev = "a7c11fbd554c3136f72e04f5fd97a0ea2b8094ca";
    hash = "sha256-ovFC3Dp4BssFntmV0KUzk4a/GYFHcWP22rfXzFDtpxg=";
  };

  # Some modules depend on being initialized in a specific order
  # by the colorscheme setup function, so they cannot be required standalone
  nvimSkipModules = [
    "moegi.theme.syntax"
    "moegi.theme.lsp"
    "moegi.theme.integrations.mini_icons"
    "moegi.theme.integrations.render_markdown"
    "moegi.theme.integrations.fzf_lua"
    "moegi.theme.integrations.ufo"
    "moegi.theme.base"
    "moegi.theme.treesitter"
  ];

  meta = {
    description = "A port of the moegi theme for neovim";
    homepage = "https://github.com/inogai/moegi.nvim";
    changelog = "https://github.com/inogai/moegi.nvim/commits/main/";
    license = lib.licenses.mit;
    maintainers = [lib.maintainers.inogai];
    mainProgram = null;
    platforms = lib.platforms.all;
  };
}
