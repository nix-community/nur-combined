{ lib, stdenv, fetchFromGitHub, rsync, ocamlPackages, nodejs }:

stdenv.mkDerivation (finalAttrs: {
  pname = "abella-master";
  version = "0-unstable-2024-11-27";

  src = fetchFromGitHub {
    owner = "abella-prover";
    repo = "abella";
    rev = "f97da8c9ea10cf2123696a1595e3e0f84b795a14";
    sha256 = "sha256-PmIyKk0lLes/JVQ8XHchKEkx3qkGv8Ssn+AEAMba70E=";
  };

  strictDeps = true;

  nativeBuildInputs = [ nodejs rsync ] ++ (with ocamlPackages; [ ocaml dune_3 menhir findlib ]);
  buildInputs = with ocamlPackages; [ cmdliner yojson ];

  installPhase = ''
    mkdir -p $out/bin
    rsync -av _build/default/src/abella.exe    $out/bin/abella

    mkdir -p $out/share/emacs/site-lisp/abella/
    rsync -av emacs/    $out/share/emacs/site-lisp/abella/

    mkdir -p $out/share/abella/examples
    rsync -av examples/ $out/share/abella/examples/
  '';

  meta = {
    description = "Interactive theorem prover";
    mainProgram = "abella";
    longDescription = ''
      Abella is an interactive theorem prover based on lambda-tree syntax.
      This means that Abella is well-suited for reasoning about the meta-theory
      of programming languages and other logical systems which manipulate
      objects with binding.
    '';
    homepage = "https://abella-prover.org";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ chen ];
    platforms = lib.platforms.unix;
  };
})
