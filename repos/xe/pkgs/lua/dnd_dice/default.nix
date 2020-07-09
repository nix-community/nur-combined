{ stdenv, fetchgit, lua5_3, rustPlatform, pkg-config }:

let
  raw = rustPlatform.buildRustPackage rec {
    pname = "dnd_dice";
    version = "git";

    buildInputs = [ pkg-config lua5_3 ];

    src = fetchgit (builtins.fromJSON (builtins.readFile ./source.json));

    cargoSha256 = "1bw39pasam6nqwfc2x6slxirghc29y5iynm3dgv119x2vk1yjk4x";
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
