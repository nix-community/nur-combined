# USAGE: nix repl -f ./repl.nix

(builtins.getFlake (toString ./.)).outputs
