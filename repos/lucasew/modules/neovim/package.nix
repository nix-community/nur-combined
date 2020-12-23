{pkgs, ...}:
let
  pluginNocapsquit = pkgs.vimUtils.buildVimPlugin {
    name = "nocapsquit";
    src = pkgs.fetchFromGitHub {
        owner = "lucasew";
        repo = "nocapsquit.vim";
        rev = "4418b78b635e797eab915bc54380a2a7e66d2e84";
        sha256 = "1jwwiq321b86bh1z3shcprgh2xs5n1xjy9s364zxlxy8qhwfsryq";
    };
  };
  pluginEmbark = pkgs.vimUtils.buildVimPlugin {
    name = "embark-theme";
    src = pkgs.fetchFromGitHub {
      owner = "embark-theme";
      repo = "vim";
      rev = "cce94a2cc9f0395ed156930bf6a2d1e3198daa4f";
      sha256 = "02wxjg8ygx7viirphdjlpqr26mdbzcpajnijlchjafy1gms0gryc";
    };
  };
  themeStarrynight = pkgs.vimUtils.buildVimPlugin {
    name = "starrynight";
    src = pkgs.fetchFromGitHub {
      owner = "josegamez82";
      repo = "starrynight";
      rev = "fcc8776f64061251a73158515a0ce82304fe4518";
      sha256 = "0zspnzgn5aixwcp7klj5vaijmj4ca6hjj58jrz5aqn10dv41s02p";
    };
  };
in pkgs.neovim.override {
  viAlias = true;
  vimAlias = true;
  configure = {
    plug.plugins = with pkgs.vimPlugins; [
      LanguageClient-neovim
      auto-pairs
      echodoc
      indentLine
      lightline-vim
      onedark-vim
      pluginNocapsquit
      vim-commentary
      vim-nix
      vim-startify
      zig-vim
      emmet-vim
      pluginEmbark
      vim-markdown
      themeStarrynight
      vim-jsx-typescript
    ];
    customRC = ''
    let g:LanguageClient_serverCommands = ${builtins.toJSON (import ./langservers.nix {inherit pkgs;})}
    set completefunc=LanguageClient#compltete
    ${builtins.readFile ./rc.vim}
    '';
  };
}
