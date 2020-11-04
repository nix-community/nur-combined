{ stdenv, buildEnv, makeWrapper, makeDesktopItem, callPackage, ncmpcpp, libnotify }:
with stdenv.lib;

let
  pname = "larbs-music";
  version = "1.0";
  voidrice = callPackage ../voidrice.nix { };
  config = "${voidrice}/.config/ncmpcpp/config";
  bindings = "${voidrice}/.config/ncmpcpp/config";
  vizNcmpcpp = ncmpcpp.override {
    visualizerSupport = true;
  };

  ncmpcppWrapped = stdenv.mkDerivation {
    inherit pname version;
    unpackPhase = "true";

    buildInputs = [ makeWrapper ];

    installPhase = ''
      makeWrapper ${vizNcmpcpp}/bin/ncmpcpp $out/bin/ncmpcpp \
      --add-flags "-c ${config}" \
      --add-flags "-b ${bindings}"
    '';

  };

  desktopItem = makeDesktopItem {
    name = pname;
    genericName = "Music player";
    comment = "Ncmpcpp music player configuration by Luke Smith";
    exec = "${ncmpcppWrapped}/bin/ncmpcpp";
    # icon =
    desktopName = pname;
    categories = "Audio;AudioVideo";
    terminal = "true";
  };

in
  buildEnv {
    name = pname;

    paths = [
      ncmpcppWrapped
      libnotify
      desktopItem
    ];

    meta = {
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
      description = "NCMPCPP music player with vim bindings";
      license = licenses.gpl3;
      platforms = [ "x86_64-linux" "x86_64-darwin" ];
    };
  }
