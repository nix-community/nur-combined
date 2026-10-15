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

let
  version = "5.0-unstable-2026-04-21";
  commit = "5ab7277c8f8528fd8825dfccd5583c64b8751e5e";
in
ocamlPackages.buildDunePackage {
  pname = "forester";
  inherit version;

  src = fetchurl {
    url = "https://git.sr.ht/~jonsterling/ocaml-forester/archive/${commit}.tar.gz";
    hash = "sha256-ungXrJFgoSRrZoQCmIN2MrotpNVGz3YlA5tsQ4AgDyE=";
  };

  strictDeps = true;

  patches = [
    ./cmdliner-env-shadow.patch
  ];

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
    changelog = "https://git.sr.ht/~jonsterling/ocaml-forester/log/${commit}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "forester";
  };
}
