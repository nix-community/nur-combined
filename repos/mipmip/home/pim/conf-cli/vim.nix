{ config, pkgs, ... }:

{
  programs.vim = {
    enable = true;

    extraConfig = ''

        if has('python2')
        endif
        if has('python3')
        endif

        for f in split(glob('~/.vim/base*.vim'), '\n')
          exe 'source' f
        endfor

        for f in split(glob('~/.vim/cli*.vim'), '\n')
          exe 'source' f
        endfor

        for f in split(glob('~/.vim/last*.vim'), '\n')
          exe 'source' f
        endfor

    '';
  };
}
