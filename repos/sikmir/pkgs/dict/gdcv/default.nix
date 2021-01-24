{ stdenv, pkg-config, emacs, zlib, sources }:

stdenv.mkDerivation {
  pname = "gdcv";
  version = stdenv.lib.substring 0 10 sources.gdcv.date;

  src = sources.gdcv;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ emacs zlib ];

  makeFlags = [ "gdcv" "emacs-module" ];

  installPhase = ''
    install -Dm755 gdcv -t $out/bin
    install -Dm644 gdcv-elisp.so gdcv.el -t $out/share/emacs/site-lisp
  '';

  meta = with stdenv.lib; {
    inherit (sources.gdcv) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
