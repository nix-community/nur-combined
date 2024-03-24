{ lib, stdenv, fetchFromGitHub, pkg-config, ocamlPackages, opaline }:

stdenv.mkDerivation rec {
  pname = "ott-sweirich";
  version = "unstable-2022-04-07";

  src = fetchFromGitHub {
    owner = "sweirich";
    repo = "ott";
    rev = "aa65f53ea0587223662aaad9c48cb0770549f018";
    hash = "sha256-OMnOzNfZNyW5CIj2eS81/wI6og5TRtf9IfuFeWfNMa8=";
  };


  strictDeps = true;

  nativeBuildInputs = [ pkg-config opaline ] ++ (with ocamlPackages; [ findlib ocaml ]);
  buildInputs = with ocamlPackages; [ ocamlgraph ];

  installTargets = "ott.install";

  postInstall = ''
    opaline -prefix $out
  ''
  # There is `emacsPackages.ott-mode` for this now.
  + ''
    rm -r $out/share/emacs
  '';

  meta = {
    description = "A tool for the working semanticist (Stephanie Weirich's fork)";
    mainProgram = "ott";
    longDescription = ''
      Ott is a tool for writing definitions of programming languages and
      calculi. It takes as input a definition of a language syntax and
      semantics, in a concise and readable ASCII notation that is close to
      what one would write in informal mathematics. It generates LaTeX to
      build a typeset version of the definition, and Coq, HOL, and Isabelle
      versions of the definition. Additionally, it can be run as a filter,
      taking a LaTeX/Coq/Isabelle/HOL source file with embedded (symbolic)
      terms of the defined language, parsing them and replacing them by
      target-system terms.
    '';
    homepage = "https://github.com/sweirich/ott";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ chen ];
    platforms = lib.platforms.unix;
  };
}
