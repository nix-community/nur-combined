{ stdenv, fetchgit }:
stdenv.mkDerivation {
  name = "dmenuunicode";

  src = fetchgit {
    url = "https://github.com/LukeSmithxyz/voidrice";
    rev = "d92bd73428f7c13ec3c3860ab8ee518c336ec458";
    sha256 = "1gjls1x3r7i0y6f3fkzhfqfv9zc6l6b2q13zygzcggqcwc3xmanm";
  };

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share
    cp .local/share/larbs/emoji $out/share

    sed -i "s:~/.local/share/larbs/emoji:$out/share/emoji:" .local/bin/dmenuunicode
    cp .local/bin/dmenuunicode $out/bin
  '';
}
