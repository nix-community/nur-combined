{
  fetchFromGitHub,
  lib,
  makeWrapper,
  ocamlPackages,
  z3,
  racket,
}:
ocamlPackages.buildDunePackage rec {
  pname = "Parsynt";
  version = "0.3";
  duneVersion = "3";
  src =
    fetchFromGitHub
    {
      owner = "victornicolet";
      repo = "parsynt";
      rev = "b70635d199dfc47378b19d4140093b7d261d753e";
      sha256 = "cJnCGDFe7scnvlHN0G31Oi156iY0+DJnkZvgoQG3VRQ=";
    };
  patches = [./diff.patch];
  preConfigure = ''
    mkdir -p $out
    cp -r $src/src $out

    project_dir_src_path=$PWD/src/utils/Project_dir.ml
    rm $project_dir_src_path || true
    touch $project_dir_src_path
    echo "let base = \"$out\"" >> $project_dir_src_path
    echo "let src = \"$out/src/\"" >> $project_dir_src_path
    echo "let templates = \"$out/src/templates/\"" >> $project_dir_src_path
    echo "let racket = \"${racket}/bin/racket\"" >> $project_dir_src_path
    echo "let z3 = \"${z3}/bin/z3\"" >> $project_dir_src_path
  '';

  nativeBuildInputs = with ocamlPackages; [menhir];

  buildInputs = with ocamlPackages; [
    getopt
    sexplib
    fmt
    stdio
    ppx_sexp_conv
    ppx_let
    fileutils
    core
    lwt
    camlp-streams
  ];
  strictDeps = true;
  preBuild = ''
    dune build Parsynt.opam
  '';

  meta = with lib; {
    description = "Automatic parallel divide-and-conquer programs synthesizer";
    homepage = "https://github.com/victornicolet/parsynt";
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
