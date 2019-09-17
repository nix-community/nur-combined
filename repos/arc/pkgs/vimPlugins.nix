{
  kotlin-vim = { fetchFromGitHub, vimUtils }: vimUtils.buildVimPlugin {
    name = "kotlin-vim";
    src = fetchFromGitHub {
      owner = "udalov";
      repo = "kotlin-vim";
      rev = "aea4336a1d66d91f1e87e8ebf2b33fd506bad74e";
      sha256 = "1nbkszhqnb1mycp07wfl49gwz3rsg7jnfnb315f7mb2b8b74rjfl";
    };
  };
  notmuch-vim = { fetchFromGitHub, vimUtils }: vimUtils.buildVimPlugin {
    name = "notmuch-vim";
    src = fetchFromGitHub {
      owner = "arcnmx";
      repo = "notmuch-vim";
      rev = "9bbadc567841ce32e399d7dab6ab037d18c74170";
      sha256 = "1mvdi6gm6khpk3nd863gcibw39xv8c2m2ri886dgw6gs8j4dn117";
    };
  };
  vim-cool = { fetchFromGitHub, vimUtils }: vimUtils.buildVimPlugin {
    name = "vim-cool";
    src = fetchFromGitHub {
      owner = "romainl";
      repo = "vim-cool";
      rev = "06918c36b3396af0bec1e87e748a5dba55be87b9";
      sha256 = "099sbjdk944bnivqgqgbjplczfm3k84583ryrmpqf3lgrq6pl8wr";
    };
  };
  vim-osc52 = { fetchFromGitHub, vimUtils }: vimUtils.buildVimPlugin {
    name = "vim-osc52";
    src = fetchFromGitHub {
      owner = "fcpg";
      repo = "vim-osc52";
      rev = "01a311169b2678d853c87b371201205daf8fdf1a";
      sha256 = "1nxla8r4036shbmyx6wpxy9ncy1s2c5ghi5n5ip22b01lcv6lnv5";
    };
  };
  vim-hug-neovim-rpc = { fetchFromGitHub, vimUtils }: vimUtils.buildVimPlugin rec {
    name = "vim-hug-neovim-rpc";
    src = fetchFromGitHub {
      owner = "roxma";
      repo = "vim-hug-neovim-rpc";
      rev = "6532acee7a06b2420160279fdd397b9d8e5f1e8a";
      sha256 = "0q6anf5f7s149ssmqfm9w4mkcgalwjflr2nh2kw0pqbwpbk925v8";
    };
  };
  oscyank = { fetchFromGitHub, vimUtils }: vimUtils.buildVimPlugin {
    name = "oscyank";
    src = fetchFromGitHub {
      owner = "greymd";
      repo = "oscyank.vim";
      rev = "c775156d8aff0a2173f147b006ff9b719fa914cb";
      sha256 = "1x6pv9v7f6psxkkskm04dar90jv61qix18q68qdwcgvacbhy1784";
    };
  };
  LanguageClient-neovim = { LanguageClient-neovim, vimUtils }: vimUtils.buildVimPluginFrom2Nix {
    inherit (LanguageClient-neovim) pname version src;

    propagatedBuildInputs = [ LanguageClient-neovim ];

    preFixup = ''
      substituteInPlace "$out"/share/vim-plugins/LanguageClient-neovim/autoload/LanguageClient.vim \
        --replace "let l:path = s:root . '/bin/'" "let l:path = '${LanguageClient-neovim}' . '/bin/'"
    '';
  };
} // import public/coc-nvim
