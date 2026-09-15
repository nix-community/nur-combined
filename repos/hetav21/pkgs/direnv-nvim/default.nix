{
  fetchFromGitHub,
  lib,
  nix-update-script,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "direnv-nvim";
  version = "0-unstable-2026-06-28";

  nvimRequireCheck = [ "direnv" ];

  # --- Source ---
  src = fetchFromGitHub {
    owner = "NotAShelf";
    repo = "direnv.nvim";
    rev = "9258f9f10c4c729d8296fce0e3ecb12543daad06";
    hash = "sha256-b5PpmkYWaDGLNcu+36tRR5ycATHYBjs9WrV8/jfmooQ=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  # --- Metadata ---
  meta = with lib; {
    description = "Direnv integration for Neovim written in Lua";
    homepage = "https://github.com/NotAShelf/direnv.nvim";
    license = licenses.mpl20;
    platforms = platforms.all;
  };
}
