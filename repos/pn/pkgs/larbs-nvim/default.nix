{ stdenv, callPackage, runCommand, vimPlugins, neovim }:
let
  voidrice = callPackage ../voidrice.nix { };
  initvim = runCommand "init.vim" { buildInputs = [ stdenv ]; }
  ''
    sed '2,/plug#end()/d' "${voidrice}/.config/nvim/init.vim" > $out
  '';
in
{ customRC ? "", packages ? []}:
neovim.override {
  configure = {
    customRC = builtins.readFile initvim + customRC;
    packages.myVimPackage = with vimPlugins; {
      # Missing packages:
      # - lukesmithxyz/airline
      # - kovetskiy/sxhkd-vim
      start = [
        vim-surround
        nerdtree
        goyo-vim
        vimagit
        vimwiki
        vim-airline
        vim-commentary
        vim-css-color
        vim-nix
      ]
      ++ packages;
    };
  };
  vimAlias = true;
  viAlias = true;
 }
