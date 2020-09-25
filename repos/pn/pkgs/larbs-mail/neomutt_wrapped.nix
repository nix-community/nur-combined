{stdenv, makeWrapper, callPackage, writeText, neomutt }:
with stdenv.lib;
let
  mutt-wizard = callPackage ./mutt-wizard.nix { };
  muttrc = writeText "muttrc" ''
    source ${mutt-wizard}/share/mutt-wizard/mutt-wizard.muttrc
    source $HOME/.config/mutt/muttrc
  '';
in
  stdenv.mkDerivation rec {
    name = "larbs-mail";
    unpackPhase = "true";

    buildInputs = [ makeWrapper ];


    installPhase = ''
      makeWrapper ${neomutt}/bin/neomutt $out/bin/neomutt \
        --add-flags "-F ${muttrc}"
    '';

    meta = {
      homepage = "https://github.com/LukeSmithXYZ/mutt-wizard";
      description = "A system for automatically configuring mutt and isync with a simple interface and safe passwords";
      license = licenses.gpl3;
      platforms = [ platforms.linux "x86_64-darwin" ];
    };
  }
