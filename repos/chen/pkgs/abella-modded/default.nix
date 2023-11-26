{ lib, stdenv, fetchFromGitHub, rsync, ocamlPackages }:

stdenv.mkDerivation rec {
  pname = "abella-modded";
  version = "unstable-2021-07-04";

  src = fetchFromGitHub {
    owner = "JimmyZJX";
    repo  = "abella";
    rev   = "c64dad15e2351433ab11fb716347fe54a8fec11e";
    hash  = "sha256-z7oO7pqjZEcZY2+W1T/T6GpY3eqRuTq5lVf7eLit5VU=";
  };

  strictDeps = true;

  nativeBuildInputs = [ rsync ] ++ (with ocamlPackages; [ ocaml ocamlbuild findlib ]);

  installPhase = ''
    mkdir -p $out/bin
    rsync -av abella    $out/bin/abella-modded

    mkdir -p $out/share/emacs/site-lisp/abella-modded/
    rsync -av emacs/    $out/share/emacs/site-lisp/abella-modded/

    mkdir -p $out/share/abella-modded/examples
    rsync -av examples/ $out/share/abella-modded/examples/
  '';

  meta = {
    description = "Interactive theorem prover (Modded by JimmyZJX)";
    longDescription = ''
      Abella is an interactive theorem prover based on lambda-tree syntax.
      This means that Abella is well-suited for reasoning about the meta-theory
      of programming languages and other logical systems which manipulate
      objects with binding.
    '';
    homepage = "https://github.com/JimmyZJX/abella";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ chen ];
    platforms = lib.platforms.unix;
  };
}
