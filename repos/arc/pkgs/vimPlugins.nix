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
  notmuch-vim = { fetchFromGitHub, fetchurl, vimUtils, notmuch, ruby, buildRubyGem, buildEnv }: vimUtils.buildVimPlugin {
    name = "notmuch-vim";
    src = fetchFromGitHub {
      owner = "mashedcode";
      repo = "notmuch-vim";
      rev = "624c1d8619290193e33898036e830c8331855770";
      sha256 = "09gy6anknphj6q3amvxynx4djbvw5blb0v851sfwjrfl9m3qi67d";
    };
    patches = [
      (let
        rev = "929c8a083292ecdba3bea63dc8ce27ef7c8158e9";
      in fetchurl {
        name = "notmuch-vim.patch";
        url = "https://github.com/mashedcode/notmuch-vim/compare/master...arcnmx:${rev}.patch";
        sha256 = "0vx24g97ij76b6a4a5l9zchpvscgy5cljydq3xnc16ramhpwk9v5";
      })
    ];
    buildPhase = let
      mail-gpg = buildRubyGem {
        inherit ruby;
        pname = "mail-gpg";
        gemName = "mail-gpg";
        source.sha256 = "13gls1y55whsjx5wlykhq8k3fi2qmkars64xdxx91vwi8pacc5p1";
        type = "gem";
        version = "0.4.2";
      };
      gemEnv = buildEnv {
        name = "notmuch-vim-gems";
        paths = with ruby.gems; [ notmuch mail gpgme rack mail-gpg ];
        pathsToLink = [ "/lib" "/nix-support" ];
      };
    in ''
      echo 'let $GEM_PATH=$GEM_PATH . ":${gemEnv}/${ruby.gemPath}"' >> plugin/notmuch.vim
      echo 'let $RUBYLIB=$RUBYLIB . ":${gemEnv}/${ruby.libPath}/${ruby.system}"' >> plugin/notmuch.vim
    '';
    meta.broken = notmuch.meta.broken or false;
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
