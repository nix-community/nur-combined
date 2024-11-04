{pkgs, ...}:

with pkgs;
vimUtils.buildVimPlugin {
  name = "vscode-nvim";
  src = fetchFromGitHub {
    owner = "Mofiqul";
    repo = "vscode.nvim";
    rev = "7de58b7a6d55fe48475d0ba2fddbcec871717761";
    sha256 = "04387gzgl8y555b3lkz9aiw9xsldfg4zmzp930m62qw8zbrvrshd";
  };
}
