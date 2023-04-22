{ vimUtils
, fetchFromGitHub
, lib
,
}:
vimUtils.buildVimPlugin {
  name = "git-conflict-nvim";
  src = fetchFromGitHub {
    owner = "akinsho";
    repo = "git-conflict.nvim";
    rev = "80bc8931d4ed8c8c4d289a08e1838fcf4741408d";
    hash = "sha256-tBKGjzKK/SftivTgdujk4NaIxz8sUNyd9ULlGKAL8x8=";
  };

  meta = with lib; {
    description = "A plugin to visualise and resolve merge conflicts in neovim";
    longDescription = ''
      git-conflict.nvim is a plugin to visualise and resolve conflicts in neovim. This plugin was inspired by conflict-marker.vim
    '';
    homepage = "https://github.com/akinsho/git-conflict.nvim";
    license = licenses.unfree; # There is no license given in the upstream code
  maintainers = with maintainers; [ minion3665 ];
  };
}
