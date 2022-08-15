{
  notmuch-vim = { fetchFromGitHub, fetchurl, vimUtils, notmuch, ruby, buildRubyGem, buildEnv, lib }:
  let
    mail-gpg = buildRubyGem {
        inherit ruby;
        pname = "mail-gpg";
        gemName = "mail-gpg";
        source.sha256 = "13gls1y55whsjx5wlykhq8k3fi2qmkars64xdxx91vwi8pacc5p1";
        type = "gem";
        version = "0.4.2";
      };
    mail = buildRubyGem {
      inherit ruby;
      pname = "mail";
      gemName = "mail";
      source.sha256 = "00wwz6ys0502dpk8xprwcqfwyf3hmnx6lgxaiq6vj43mkx43sapc";
      type = "gem";
      version = "2.7.1";
    };
  in vimUtils.buildVimPlugin {
    pname = "notmuch-vim";
    version = "2018-08-23";
    src = fetchFromGitHub {
      owner = "mashedcode";
      repo = "notmuch-vim";
      rev = "624c1d8619290193e33898036e830c8331855770";
      sha256 = "09gy6anknphj6q3amvxynx4djbvw5blb0v851sfwjrfl9m3qi67d";
    };
    patches = [
      (let
        rev = "978cf7a4f0febe900abdb7b2afc4e0490c278ed4";
      in fetchurl {
        name = "notmuch-vim.patch";
        url = "https://github.com/mashedcode/notmuch-vim/compare/master...arcnmx:${rev}.patch";
        sha256 = "08jny1aswvzi7zpj4isf8sq2zf619kd4a6m3r4fyg1nkjcn3ikci";
      })
    ];
    gemEnv = buildEnv {
      name = "notmuch-vim-gems";
      paths = with ruby.gems; [ mail gpgme rack mail-gpg ]
      ++ lib.optional (notmuch ? ruby) notmuch.ruby;
      pathsToLink = [ "/lib" "/nix-support" ];
    };
    buildPhase = let
    in ''
      cat >> plugin/notmuch.vim << EOF
      let \$GEM_PATH=\$GEM_PATH . ":$gemEnv/${ruby.gemPath}"
      let \$RUBYLIB=\$RUBYLIB . ":$gemEnv/${ruby.libPath}/${ruby.system}"
      if has('nvim')
      EOF
      for gem in $gemEnv/${ruby.gemPath}/gems/*/lib; do
      echo "ruby \$LOAD_PATH.unshift('$gem')" >> plugin/notmuch.vim
      done
      echo 'endif' >> plugin/notmuch.vim
    '';
    meta.broken = notmuch.meta.broken or false || ! notmuch ? ruby;
  };
  vim-hug-neovim-rpc = { fetchFromGitHub, vimUtils }: vimUtils.buildVimPlugin rec {
    pname = "vim-hug-neovim-rpc";
    version = "2021-05-14";
    src = fetchFromGitHub {
      owner = "roxma";
      repo = "vim-hug-neovim-rpc";
      rev = "93ae38792bc197c3bdffa2716ae493c67a5e7957";
      sha256 = "0v7940h1sy8h6ba20qdadx82zbmi9mm4yij9gsxp3d9n94av8zsx";
    };
  };
}
