{
  lib,
  stdenv,
  fetchFromGitHub,
  automake,
  autoconf,
  ocaml,
  ocamlPackages,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coccinelle";
  version = "1.3.1";
  src = fetchFromGitHub {
    owner = "coccinelle";
    repo = "coccinelle";
    rev = finalAttrs.version;
    sha256 = "sha256-ZNWuloXhAXWNNoVWLOuDbC3e6KNL7nzM2346tB04qXA=";
  };

  configurePhase = ''
  runHook preConfigure
  ./autogen
  ./configure
  runHook postConfigure
  '';
  
  installPhase = ''
  runHook preInstall
  mkdir -pv $out/usr/local/bin $out/usr/local/lib/coccinelle
  mkdir -p $out/bin $out/lib/coccinelle
  mkdir -p $out/lib/coccinelle/ocaml
  if test -f bundles/pyml/dllpyml_stubs.so; then \
	install -c -m 755 bundles/pyml/dllpyml_stubs.so \
		$out/lib/coccinelle; \
  fi
  if test -f bundles/pcre/dllpcre_stubs.so; then \
	install -c -m 755 bundles/pcre/dllpcre_stubs.so \
		$out/lib/coccinelle; \
  fi
  install -c -m 755 spatch.opt $out/bin/spatch
  install -c -m 644 standard.h $out/lib/coccinelle
  install -c -m 644 standard.iso $out/lib/coccinelle
  install -c -m 644 ocaml/*.cmi $out/lib/coccinelle/ocaml/
  if test -f ocaml/coccilib.cmx; then \
	install -c -m 644 ocaml/*.cmx $out/lib/coccinelle/ocaml/; \
  fi
  install -c -m 755 tools/spgen/source/spgen.opt \
	$out/bin/spgen
  mkdir -p $out/lib/coccinelle/python/coccilib
  install -c -m 644 python/coccilib/*.py \
	$out/lib/coccinelle/python/coccilib
  if test "x$out/share/bash-completion/completions" != "xno"; then \
	mkdir -p $out/share/bash-completion/completions; \
	install -c -m 644 scripts/spatch.bash_completion \
		$out/share/bash-completion/completions/spatch; \
  fi
  mkdir -p $out/share/man/man1
  mkdir -p $out/share/man/man3
  install -c -m 644 docs/spatch.1 $out/share/man/man1/
  install -c -m 644 docs/pycocci.1 $out/share/man/man1/
  install -c -m 644 docs/spgen.1 $out/share/man/man1/
  install -c -m 644 docs/Coccilib.3cocci $out/share/man/man3/
  if test "x$out/share/metainfo" != "xno"; then \
	mkdir -p $out/share/metainfo; \
	install -c -m 644 extra/io.github.coccinelle.coccinelle.metainfo.xml \
		$out/share/metainfo/io.github.coccinelle.coccinelle.metainfo.xml; \
  fi
  runHook postInstall
  '';

  nativeBuildInputs = [
    ocamlPackages.menhirLib
  ];

  buildInputs = [ 
    automake
    autoconf
    ocaml
    ocamlPackages.findlib
    ocamlPackages.menhir
    pkg-config
  ];

  meta = {
    description = "Program matching and transformation engine";
    longDescription = ''
      Coccinelle allows programmers to easily write some complex
      style-preserving source-to-source transformations on C source code,
      like for instance to perform some refactorings.
    '';
    homepage = "https://coccinelle.gitlabpages.inria.fr/website/";
    license = lib.licenses.gpl2;
    mainProgram = [ "spatch" "spgen" ];
  };
})
