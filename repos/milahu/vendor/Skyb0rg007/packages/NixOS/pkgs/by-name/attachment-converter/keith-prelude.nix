{
  lib,
  fetchurl,
  stdenv,
  gnumake,
  ocaml,
  findlib,
  ocaml_make,
  camlp-streams,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "keith-prelude";
  version = "100.7";

  src = fetchurl {
    url = "https://www.lib.uchicago.edu/keith/hg/prelude-${finalAttrs.version}.tar.gz";
    hash = "sha256-H9vgGWl5PIgJKHqAi8xr0RwVxY9BHOtS+o0cwUqcj04=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gnumake
    ocaml
    findlib
    ocaml_make
  ];
  propagatedBuildInputs = [ camlp-streams ];

  createFindlibDestdir = true;

  preBuild = ''
    makeFlagsArray+=(
      OCAMLMAKEFILE="$OCAMLMAKEFILE"
      OCAMLFIND_INSTFLAGS="-destdir $OCAMLFIND_DESTDIR")
  '';

  meta = {
    homepage = "https://www.lib.uchicago.edu/keith/software/prelude/";
    description = "OCaml standard library additions and renamings";
    license = lib.licenses.gpl2Plus;
    inherit (ocaml.meta) platforms;
  };
})
