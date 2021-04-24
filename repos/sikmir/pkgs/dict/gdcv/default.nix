{ lib, stdenv, fetchFromGitHub, pkg-config, emacs, zlib }:

stdenv.mkDerivation rec {
  pname = "gdcv";
  version = "2020-05-14";

  src = fetchFromGitHub {
    owner = "konstare";
    repo = pname;
    rev = "39fd2667362710f69c13dd596e112b0391e0a57e";
    hash = "sha256-JmT6n+VC6bbOOg+j+3bpUaoMn/Wr2Q4XDbQ6kxuLNe0=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ emacs zlib ];

  makeFlags = [ "gdcv" "emacs-module" ];

  installPhase = ''
    install -Dm755 gdcv -t $out/bin
    install -Dm644 gdcv-elisp.so gdcv.el -t $out/share/emacs/site-lisp
  '';

  meta = with lib; {
    description = "GoldenDict console version and emacs dynamic module";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
