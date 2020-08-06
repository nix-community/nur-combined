{ stdenv, fetchFromGitHub, dmenu, xclip, libnotify, xdotool, }:

stdenv.mkDerivation {
  name = "emojipicker";

  src = fetchFromGitHub {
    owner = "LukeSmithxyz";
    repo = "voidrice";
    rev = "72926c0c4422f2b3e1444e3c7a0b7cd35294e1a4";
    sha256 = "19rr05gyv4v2vzl84fq2mhrkkq3rdfw9bq3z1c01wx5wwimp83ba";
  };

  patchPhase = ''
    cd .local/bin
    patchShebangs dmenuunicode
    substituteInPlace dmenuunicode \
      --replace "~/.local" "$out/.local" \
      --replace dmenu ${dmenu}/bin/dmenu \
      --replace xclip ${xclip}/bin/xclip \
      --replace notify-send ${libnotify}/bin/notify-send \
      --replace xdotool ${xdotool}/bin/xdotool
    cd -
  '';

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin
    cp .local/bin/dmenuunicode $out/bin/emojipicker
    mkdir -p $out/.local/share/larbs
    cp .local/share/larbs/emoji $out/.local/share/larbs/emoji
  '';
}
