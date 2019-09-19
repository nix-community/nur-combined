{ pkgs ? import <nixpkgs> {}
, stdenvNoCC ? pkgs.stdenvNoCC
, ...
}:
with pkgs;
let
  python-requirements = ps : with ps; [
    numpy
    requests
    appdirs
  ];
  python-package = (python3.withPackages python-requirements);
in
stdenvNoCC.mkDerivation rec {
   name = "drinklist-cli";

   meta = {
     homepage = https://github.com/FIUS/drinklist-cli;
     description = "A CLI for the FIUS drinklsit";
     license = stdenv.lib.licenses.gpl3;
   };

   src = fetchFromGitHub {
     owner = "FIUS";
     repo = "drinklist-cli";
     rev = "77886adac9079baf71c3d2174e85f9094efd89f3";
     sha256 = "103i65xdqjakw86nr0npla452qhjqhq6f5jkhyl11afx3csa5j3f";
   };

   dontBuild = true;
   nativeBuildInputs = [ makeWrapper ];
   buildInputs = [ python-package ];
   installPhase = ''
     mkdir -p $out/bin
     mkdir -p $out/opt
     for file in ./src/*
     do
       cp -r $file $out/opt/
     done
     makeWrapper $out/opt/drink.py $out/bin/drinklist
     makeWrapper $out/opt/drink.py $out/bin/drink --add-flags drink

     # Link bash completion
     mkdir -p $out/etc/bash_completion.d
     ln -s $out/opt/bash_completions.sh $out/etc/bash_completion.d/drinklist.bash-completion
     mkdir -p $out/share/bash-completion/completions
     ln -s $out/opt/bash_completions.sh $out/share/bash-completion/completions/drinklist
     ln -s $out/opt/bash_completions.sh $out/share/bash-completion/completions/drinklist.bash-completion

     # Link zsh completion
     mkdir -p $out/share/zsh/site-functions
     ln -s $out/opt/zsh_completion_drinklist.zsh $out/share/zsh/site-functions/_drinklist
     ln -s $out/opt/zsh_completion_drink.zsh $out/share/zsh/site-functions/_drink
     ln -s $out/opt/zsh_completion_helpers.zsh $out/share/zsh/site-functions/_drinklist_completion_helpers
   '';
}
