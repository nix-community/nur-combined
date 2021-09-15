{
  notmuch-vim = { fetchFromGitHub, fetchurl, vimUtils, notmuch, ruby, buildRubyGem, buildEnv }:
  let
    mail-gpg = buildRubyGem {
        inherit ruby;
        pname = "mail-gpg";
        gemName = "mail-gpg";
        source.sha256 = "13gls1y55whsjx5wlykhq8k3fi2qmkars64xdxx91vwi8pacc5p1";
        type = "gem";
        version = "0.4.2";
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
        rev = "929c8a083292ecdba3bea63dc8ce27ef7c8158e9";
      in fetchurl {
        name = "notmuch-vim.patch";
        url = "https://github.com/mashedcode/notmuch-vim/compare/master...arcnmx:${rev}.patch";
        sha256 = "0vx24g97ij76b6a4a5l9zchpvscgy5cljydq3xnc16ramhpwk9v5";
      })
    ];
    gemEnv = buildEnv {
      name = "notmuch-vim-gems";
      paths = with ruby.gems; [ notmuch mail gpgme rack mail-gpg ];
      pathsToLink = [ "/lib" "/nix-support" ];
      # https://github.com/NixOS/nixpkgs/pull/76765
      postBuild = ''
        for gem in $out/lib/ruby/gems/*/gems/*; do
          cp -a $gem/ $gem.new
          rm $gem
          mv $gem.new $gem
        done
      '';
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
    meta.broken = notmuch.meta.broken or false;
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
