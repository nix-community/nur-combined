{ stdenvNoCC
, pkgs ? import <nixpkgs> {}
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
     rev = "b86c7bf3b23b72d1eaf876374f42e9fc8770f1f8";
     sha256 = "01qskw3j8yg5nw0s0pqwlv3pjc4rrj8ff3687ll8lmbj2wcfy003";
   };

   dontBuild = true;
   nativeBuildInputs = [ makeWrapper ];
   buildInputs = [ python-package ];
   installPhase = ''
     mkdir -p $out/bin
     mkdir -p $out/opt
     for file in ./*
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
   '';
}
