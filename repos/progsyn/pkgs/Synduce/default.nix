{
  fetchFromGitHub,
  lib,
  makeWrapper,
  ocamlPackages,
  z3,
  cvc4,
  cvc5,
}: let
  parsexp_io = ocamlPackages.buildDunePackage rec {
    pname = "parsexp_io";
    version = "v0.17.0";
    duneVersion = "3";
    src =
      fetchFromGitHub
      {
        owner = "janestreet";
        repo = "parsexp_io";
        rev = version;
        sha256 = "r1HXO3VJ167QUgz4UIQuB5sY6p10FLE3Jrp9NmoDKoE=";
      };
    buildInputs = with ocamlPackages; [
      ppx_js_style
      parsexp
    ];
    strictDeps = true;
    preBuild = ''
      dune build parsexp_io.opam
    '';
  };
in
  ocamlPackages.buildDunePackage rec {
    pname = "Synduce";
    version = "0.2";
    duneVersion = "3";
    src =
      fetchFromGitHub
      {
        owner = "synduce";
        repo = "Synduce";
        rev = "b5c1d1611d3fbf5d8cdf9a23fde52c2cbba95a89";
        sha256 = "hgdN9IK1cv/IepaqGDzXXgKHqN2jtYWqWu9N4ejEYI4=";
      };
    patches = [./deps.patch];
    preConfigure = ''
      mkdir -p $out
      cp -r $src/src $out

      bin_path_src_path=$PWD/src/utils/DepPath.ml
      rm $bin_path_src_path || true
      touch $bin_path_src_path

      echo "let cvc4_binary_path = Some(\"${cvc4}/bin/cvc4\")" >> $bin_path_src_path
      echo "let cvc5_binary_path = Some(\"${cvc5}/bin/cvc5\")" >> $bin_path_src_path
      echo "let z3_binary_path = \"${z3}/bin/z3\"" >> $bin_path_src_path
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
      core_unix
      lwt
      lwt_ppx
      camlp-streams
      menhir
      yojson
      ppx_deriving
      ocamlgraph
      menhirLib
      parsexp_io
    ];
    strictDeps = true;
    preBuild = ''
      dune build Synduce.opam
    '';

    meta = with lib; {
      description = "An automatic recursive function transformer";
      homepage = "https://github.com/synduce/Synduce";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  }
