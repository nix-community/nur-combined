{pkgs, ...}:

with pkgs;
vimUtils.buildVimPlugin {
  name = "vscode-nvim";
  src = fetchFromGitHub {
    owner = "Mofiqul";
    repo = "vscode.nvim";
    rev = "aa1102a7e15195c9cca22730b09224a7f7745ba8";
    sha256 = "sha256-YGlTlHEuivPJzMyWfk+YmbZqftbj7Mrll8rB3vK3O2A=";
  };
  meta = with lib; {
    description = "Neovim/Vim color scheme inspired by Dark+ and Light+ theme in Visual Studio Code";
    homepage = "https://github.com/Mofiqul/vscode.nvim";
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
    license = with licenses; [ mit ];
  };
}
