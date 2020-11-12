let
    global = import ./globalConfig.nix;
    pkgs = import global.repos.nixpkgs {};
in pkgs.mkShell {
    shellHook = ''
    export DOTFILES=$(pwd)
    ${global.setupScript}

    echo Ambiente carregado!
    '';
}
