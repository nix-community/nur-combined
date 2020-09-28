{ stdenv, makeWrapper, callPackage, newsboat }:
with stdenv.lib;

let
  voidrice = callPackage ../voidrice.nix { };
  newsboatConfig = "${voidrice}/.config/newsboat/config";
in

stdenv.mkDerivation {
  pname = "larbs-news";
  version = "1.0";
  unpackPhase = "true";

  buildInputs = [ makeWrapper ];

  installPhase = ''
    makeWrapper ${newsboat}/bin/newsboat $out/bin/newsboat \
      --add-flags "-C ${newsboatConfig}"
  '';

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/voidrice";
    description = "Newsboat RSS reader with vim bindings";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
  };
}
