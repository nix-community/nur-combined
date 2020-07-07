{ stdenv, fetchgit, lua5_3, rustPlatform, pkg-config }:

let
  raw = rustPlatform.buildRustPackage rec {
    pname = "dnd_dice";
    version = "git";

    buildInputs = [ pkg-config lua5_3 ];

    src = fetchgit (builtins.fromJSON (builtins.readFile ./source.json));

    cargoSha256 = "0djglan754sh6d4rx76c1kwjzx0g1ifbx1xl94zazpsfx44m5nw0";
    verifyCargoDeps = false;
  };
in stdenv.mkDerivation {
  inherit (raw) name;
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/lib/lua/5.3
    ln -s ${raw}/lib/libdnd_dice.so $out/lib/lua/5.3/dnd_dice.so
  '';
}
