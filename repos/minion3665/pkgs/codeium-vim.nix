{ vimUtils
, lib
, fetchFromGitHub
}: vimUtils.buildVimPluginFrom2Nix { 
  name = "codeium.vim";
  src = fetchFromGitHub {
    owner = "Exafunction";
    repo = "codeium.vim";
    rev = "cf3bbfa52658fa4380ea2bb764493356f04768c3";
    sha256 = "sha256-HoTw330lS4bvJJaukZgbTTzr8t5O8mMkpHqi+dF8jqY=";
  };

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
