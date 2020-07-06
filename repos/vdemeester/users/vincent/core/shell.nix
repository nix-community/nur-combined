{ config, ... }: {
  aliases = {
    mkdir = ''mkdir --parents --verbose'';
    rm = ''rm --interactive'';
    cp = ''cp --interactive'';
    mv = ''mv --interactive'';
    gcd = ''cd (git root)'';
    ls = ''exa'';
    ll = ''exa --long'';
    la = ''exa --all'';
    l = ''exa --long --all --header'';
    t = ''exa --tree --level=2'';
    wget = ''wget -c'';
    map = ''xargs -n1'';
  };

  env = ''
    export PATH=$HOME/bin:$PATH
    export LESSHISTFILE="${config.xdg.dataHome}/less_history"
    export GOPATH=${config.home.homeDirectory}
    export WEBKIT_DISABLE_COMPOSITING_MODE=1;
    export PATH=$HOME/bin:$PATH
    if [ -d $HOME/.krew/bin ]; then
      export PATH=$HOME/.krew/bin:$PATH
    fi
  '';

  historySize = 10000;
}
