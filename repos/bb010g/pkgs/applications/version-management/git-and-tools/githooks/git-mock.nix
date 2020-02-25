{ stdenv }:

stdenv.writeScriptBin "git" (builtins.readFile ./git-mock.sh)
