{ vimUtils
, lib
, fetchFromGitHub
}: vimUtils.buildVimPluginFrom2Nix rec { 
  name = "codeium.vim";
  version = "1.2.26";
  src = fetchFromGitHub {
    owner = "Exafunction";
    repo = "codeium.vim";
    rev = version;
    sha256 = "sha256-gc4BP4ufE6UPJanskhvoab0vTM3t5b2egPKaV1X5KW0=";
  };

  patches = [ ../patches/codeium-vim/wrap-with-steam-run.patch ];

  meta = with lib; {
    description = "Free, ultrafast Copilot alternative for Vim and Neovim";
    longDescription = ''
      codeium.vim is a free, ultrafast Copilot alternative for Vim and Neovim

      Codeium autocompletes your code with AI in all major IDEs. The Codeium team launched this implementation of the Codeium plugin for Vim and Neovim to bring this modern coding superpower to more developers. Check out the playground if you want to quickly try out Codeium online

    '';
    homepage = "https://codeium.com/";
    license = licenses.mit;
    maintainers = with maintainers; [ minion3665 ];
  };
}
