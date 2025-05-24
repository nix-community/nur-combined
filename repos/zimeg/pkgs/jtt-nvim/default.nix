{
  lib,
  fetchFromGitHub,
  vimUtils,
}:

vimUtils.buildVimPlugin {
  pname = "jtt.nvim";
  version = "unversioned";

  src = fetchFromGitHub {
    owner = "herisetiawan00";
    repo = "jtt.nvim";
    rev = "f8959ff739d31bd7c5aae99748f248d58e9fbfc9";
    hash = "sha256-/bO9tgaRI+B9T4K3zxhfvz0Y2OKXBEomZaMwISHbiXc=";
  };

  meta = with lib; {
    homepage = "https://github.com/herisetiawan00/jtt.nvim";
    description = "Neovim simple Jump-to-Test plugin";
    license = licenses.mit;
  };
}
