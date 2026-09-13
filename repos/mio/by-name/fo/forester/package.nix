{
  lib,
  stdenv,
  pkgs,
  fetchurl,
  cid,
  datalog,
  ocaml-index,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "forester";
  version = "39b920d624233c1aa39402cad69ad17c3895581d";

  src = fetchurl {
    url = "https://git.sr.ht/~jonsterling/ocaml-forester/archive/${version}.tar.gz";
    hash = "sha256-V4ORZtm0OxaoEF5CT6oNQtLctmtsrWRilBSHGOacaPc=";
  };

  strictDeps = true;

  nativeBuildInputs =
    with ocamlPackages;
    [
      js_of_ocaml-compiler
      menhir
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin pkgs.darwin.sigtool;

  propagatedBuildInputs = with ocamlPackages; [
    alcotest
    algaeff
    asai
    base64
    bisect_ppx
    bwd
    brr
    cid
    cmdliner
    cohttp-eio
    datalog
    dune-build-info
    dune-site
    eio_main
    grace
    jsonrpc
    jsont
    logs
    lsp
    ocaml-index
    ocamlgraph
    ppx_deriving
    ppx_repr
    ppx_yojson_conv
    progress
    ptime
    pure-html
    repr
    routes
    spelll
    toml
    uri
    uucp
    yojson
    yuujinchou
  ];

  preBuild = ''
    rm -rf docs
  '';

  meta = {
    description = "Tool for tending mathematical forests";
    homepage = "https://sr.ht/~jonsterling/forester/";
    changelog = "https://git.sr.ht/~jonsterling/ocaml-forester/log/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "forester";
  };
}
