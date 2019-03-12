{ stdenv }:

stdenv.mkDerivation {
  name = "dotfiles-bin";
  src = ../../dotfiles;
  installPhase = ''
    mkdir -p $out/lib/dotfiles
    cp -r ./* $out/lib/dotfiles
    cp -r ./share $out/share
    mv $out/lib/dotfiles/bin $out/bin
    cat <<EOF > $out/bin/dotfiles
    #!/usr/bin/env bash

    echo $out/lib/dotfiles
    EOF
    chmod +x $out/bin/dotfiles
  '';
}
