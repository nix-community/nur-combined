{ global, self, ... }:
{
  programs.bash.promptInit = ''
    function dotfilesDir {
      if [ -d ~/.dotfiles ]; then
        echo ~/.dotfiles
      elif [ -d /home/lucasew/.dotfiles ]; then
        echo /home/lucasew/.dotfiles
      else
        echo ${self}
      fi
    }

    function loadDotfilesEnv {
      ${global.environmentShell}
    }

    function loadBinEnv {
      export PATH="$PATH:${../../../bin}"
    }
  '';
}
