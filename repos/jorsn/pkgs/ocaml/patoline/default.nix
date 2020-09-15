{ config, lib, fetchurl, fetchFromGitHub, buildDunePackage, makeWrapper
, ocaml, findlib
, earley, camlzip, ocaml_sqlite3, imagelib, imagelib-unix
}:

buildDunePackage rec {
  minimumOCamlVersion = "4.03";
  maximumOCamlVersion = "4.07.1";
  version = "2020-04-10";
  pname = "patoline";

  src = config.sources.patoline;

  #doCheck = true;
  #doInstallCheck = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ earley camlzip ocaml_sqlite3 imagelib imagelib-unix ];

  patches = [
    ./imagelib-unix.patch
  ];
  postPatch = ''
    for f in unicodelib/config.ml patconfig/patDefault.ml; do
      substituteInPlace "$f" --replace /usr/local $out
    done
  '';
  #preConfigure="export PREFIX=$out";

  # patoline needs an ocaml dev env
  preFixup = ''
    wrapProgram $out/bin/patoline \
      --prefix PATH : ${lib.makeBinPath [ ocaml findlib ]} \
      --prefix OCAMLPATH : $OCAMLPATH \
      --prefix OCAMLPATH : $OCAMLFIND_DESTDIR \
      --prefix CAML_LD_LIBRARY_PATH : $CAML_LD_LIBRARY_PATH \
      --prefix NIX_LDFLAGS ' ' "$NIX_LDFLAGS" \
      --set NIX_CC_WRAPPER_x86_64_unknown_linux_gnu_TARGET_HOST "$NIX_CC_WRAPPER_x86_64_unknown_linux_gnu_TARGET_HOST"
  '';

  meta = {
    description = "Patoline typesetting system";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    homepage = "https://github.com/patoline/patoline";
  };
}
