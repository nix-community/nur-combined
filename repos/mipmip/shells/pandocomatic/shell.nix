{ pkgs ? import <nixpkgs> { } }:
with pkgs;

mkShell {
  buildInputs = [
    ruby_2_7
    pandoc
  ];
  shellHook = ''
    mkdir -p .nix-gems
    export GEM_HOME=$PWD/.nix-gems-pandocomatic
    export GEM_PATH=$GEM_HOME
    export PATH=$GEM_HOME/bin:$PATH
    export PATH=$PWD/bin:$PATH

    gem list -i ^bundler$ -v 1.17.3 || gem install bundler --version=1.17.3 --no-document
    bundle
  '';
}
