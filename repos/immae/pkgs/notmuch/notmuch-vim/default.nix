{ stdenv, notmuch }:
stdenv.mkDerivation rec {
  name = "notmuch-vim-${version}";
  version = notmuch.version;
  outputs = [ "out" ];
  src = notmuch.src;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    make -C vim DESTDIR=$out prefix="/share/vim/vimfiles" install
    '';
}
