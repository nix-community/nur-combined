{pkgs, ...}:

with pkgs;
vimUtils.buildVimPlugin {
  name = "vscode-nvim";
  src = fetchFromGitHub {
    owner = "Mofiqul";
    repo = "vscode.nvim";
    rev = "7de58b7a6d55fe48475d0ba2fddbcec871717761";
    sha256 = "sha256-ZKq3oVz9kZjFv/JeFiy5TPKf8kOgY/cpPgL42oopWDU=";
  };
  meta = with lib; {
    description = "Neovim/Vim color scheme inspired by Dark+ and Light+ theme in Visual Studio Code";
    homepage = "https://github.com/Mofiqul/vscode.nvim";
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
    license = with licenses; [ mit ];
  };
}
