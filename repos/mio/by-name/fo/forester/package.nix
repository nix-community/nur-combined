{
  lib,
  stdenv,
  pkgs,
  fetchurl,
  cid,
  ocaml-index,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "forester";
  version = "d1b3651b9352251dd1e7f4e77c1465343f9b0735";

  src = fetchurl {
    url = "https://git.sr.ht/~jonsterling/ocaml-forester/archive/${version}.tar.gz";
    hash = "sha256-B0TxfIs6AGI8IY29zOiP1xPZxIMqexO/XJQ3TAoJgs0=";
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
    ppx_deriving_yojson
    ppx_yojson_conv
    progress
    ptime
    pure-html
    routes
    saturn
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
