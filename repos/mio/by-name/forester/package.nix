{
  lib,
  fetchurl,
  cid,
  datalog,
  ocaml-index,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "forester";
  version = "5ab7277c8f8528fd8825dfccd5583c64b8751e5e";

  src = fetchurl {
    url = "https://git.sr.ht/~jonsterling/ocaml-forester/archive/${version}.tar.gz";
    hash = "sha256-ungXrJFgoSRrZoQCmIN2MrotpNVGz3YlA5tsQ4AgDyE=";
  };

  strictDeps = true;

  patches = [
    ./cmdliner-env-shadow.patch
  ];

  nativeBuildInputs = with ocamlPackages; [
    js_of_ocaml-compiler
    menhir
  ];

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
    jsonrpc
    logs
    lsp
    ocaml-index
    ocamlgraph
    ppx_deriving
    ppx_repr
    ppx_yojson_conv
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

  meta = {
    description = "Tool for tending mathematical forests";
    homepage = "https://sr.ht/~jonsterling/forester/";
    changelog = "https://git.sr.ht/~jonsterling/ocaml-forester/log/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "forester";
  };
}
