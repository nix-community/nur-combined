{ callPackage, fetchgit, fetchpatch, autoreconfHook, lib, stdenv
, ocamlPackages, coqPackages, rubber, hevea, emacs }:

stdenv.mkDerivation rec {
  pname = "why3";
  version = "2022-07-13";

  src = fetchgit {
    url = "https://gitlab.inria.fr/why3/why3.git";
    rev = "e262875c";
    sha256 = "sha256-iKqwsKmyvQ9KMF/q+BjQnBywxgFaP5uO7z1jU6cmgx4=";
  };

  buildInputs = with ocamlPackages; [
    ocaml findlib ocamlgraph zarith menhir
    # Emacs compilation of why3.el
    emacs
    # Documentation
    rubber hevea
    # GUI
    lablgtk3-sourceview3
    # WebIDE
    js_of_ocaml js_of_ocaml-ppx
    # S-expression output for why3pp
    ppx_deriving ppx_sexp_conv
  ] ++ (with coqPackages; [ coq flocq ]);

  nativeBuildInputs = [ autoreconfHook ];
  propagatedBuildInputs = with ocamlPackages; [ camlzip menhirLib num re sexplib ];

  enableParallelBuilding = true;

  configureFlags = [ "--enable-verbose-make" ];
  installTargets = [ "install" "install-lib" ];

  # passthru.withProvers = callPackage ./with-provers.nix {};

  meta = with lib; {
    description = "A platform for deductive program verification";
    homepage    = "http://why3.lri.fr/";
    license     = licenses.lgpl21;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ thoughtpolice vbgl ];
  };
}
