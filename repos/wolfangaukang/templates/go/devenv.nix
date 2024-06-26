{ pkgs
, ...
}:

let
  inherit (pkgs) golangci-lint;

in {
  packages = [
    golangci-lint
  ];

  languages = {
    go.enable = true;
    nix.enable = true;
  };

  enterShell = ''
    export GOPATH=$HOME/.go
    export PATH="$GOPATH/bin:$PATH"
  '';
}
