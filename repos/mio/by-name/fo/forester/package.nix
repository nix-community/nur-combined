{
  lib,
  stdenv,
  pkgs,
  fetchurl,
  cid,
  ocaml-index,
  ocamlPackages,
}:

let
  version = "6.0.0-unstable-2026-11-13";
  commit = "5cff94df38ef9f6bc8eaac361d84a6d8bb655fda";
  lspSrc = fetchurl {
    url = "https://github.com/ocaml/ocaml-lsp/releases/download/1.28.1/lsp-1.28.1.tbz";
    hash = "sha256-ErUjebk01plnO9gmuhbiBodVWu3O/FWjnGivu2IPuhk=";
  };
  lspPostPatch = ''
    substituteInPlace dune-project \
      --replace-fail '(lang dune 3.24)' '(lang dune 3.23)'
  '';
  ocamlPkgs = ocamlPackages.overrideScope (
    _: osuper: {
      jsonrpc = osuper.jsonrpc.overrideAttrs (_: {
        version = "1.28.1";
        src = lspSrc;
        postPatch = lspPostPatch;
      });
      lsp = osuper.lsp.overrideAttrs (_: {
        version = "1.28.1";
        src = lspSrc;
        postPatch = lspPostPatch;
        doCheck = false;
      });
    }
  );
in
ocamlPkgs.buildDunePackage {
  pname = "forester";
  inherit version;

  src = fetchurl {
    url = "https://git.sr.ht/~jonsterling/ocaml-forester/archive/${commit}.tar.gz";
    hash = "sha256-XpanZb8LQBn3uILmZ5WAMjh/zQ5/7W921c3w9QlYpGo=";
  };

  strictDeps = true;

  nativeBuildInputs =
    with ocamlPkgs;
    [
      js_of_ocaml-compiler
      menhir
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin pkgs.darwin.sigtool;

  propagatedBuildInputs = with ocamlPkgs; [
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

  postPatch = ''
    # nixpkgs ships dune 3.23; forester 6.0 only bumped the declared lang version
    # without using 3.25-only stanzas.
    substituteInPlace dune-project \
      --replace-fail '(lang dune 3.25)' '(lang dune 3.23)'
    # eio 1.7 added an optional ?config argument to Eio_main.run, which
    # prevents passing Eio_main.run directly to `let@`.
    for f in $(grep -rl 'let@ env = Eio_main.run in' bin lib); do
      substituteInPlace "$f" \
        --replace-fail 'let@ env = Eio_main.run in' 'let@ env = (fun k -> Eio_main.run k) in'
    done
  '';

  preBuild = ''
    rm -rf docs
  '';

  meta = {
    description = "Tool for tending mathematical forests";
    homepage = "https://sr.ht/~jonsterling/forester/";
    changelog = "https://git.sr.ht/~jonsterling/ocaml-forester/log/${commit}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "forester";
  };
}
