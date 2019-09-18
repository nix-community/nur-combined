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
     rev = "942606d97b8db53c1723e875f5b09c2ba19e6dc7";
     sha256 = "1bsjsg736lviqvm20vds5bkyfkyx47f95g2g5spv4fc4jw11r21k";
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
   '';
}
