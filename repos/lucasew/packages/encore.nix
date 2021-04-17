{pkgs ? import <nixpkgs> {}}:
let
  encore_common = ''
    export ENCORE_INSTALL="$HOME/.encore"
    export ENCORE_RUNTIME_PATH="$ENCORE_INSTALL/runtime"
    export ENCORE_GOROOT="$ENCORE_INSTALL/encore-go"
    PATH="$ENCORE_INSTALL/bin:${pkgs.gcc}/bin:$PATH"
  '';
  encore = pkgs.writeShellScriptBin "encore" ''
    ${encore_common}
    encore "$@"
  '';
  git-remote-encore = pkgs.writeShellScriptBin "git-remote-encore" ''
    ${encore_common}
    git-remote-encore "$@"
  '';
  encore_install = pkgs.writeShellScriptBin "encore-install" ''
    ${encore_common}
    rm -rf "$ENCORE_INSTALL" || true # if it does not exists no problem
    PATH=$PATH:${pkgs.python3}/bin
    curl -L https://encore.dev/install.sh | bash
  '';
in pkgs.symlinkJoin {
  name = "encore";
  version = "latest";
  paths = [
    encore
    encore_install
    git-remote-encore
  ];
}
