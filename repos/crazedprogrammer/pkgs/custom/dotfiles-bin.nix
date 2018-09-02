{ stdenv }:

stdenv.mkDerivation {
  name = "dotfiles-bin";
  src = ../../dotfiles;
  installPhase = ''
    mkdir -p $out/lib/dotfiles
    cp -r ./* $out/lib/dotfiles
    mv $out/lib/dotfiles/bin $out/bin
    cat <<EOF > $out/bin/dotfiles
    #!/usr/bin/env bash

    echo $out/lib/dotfiles
    EOF
    chmod +x $out/bin/dotfiles
  '';
}
