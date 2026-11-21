{
  lib,
  stdenv,
  pkgs,
  fetchgit,
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

  # git.sr.ht is behind an Anubis bot check that rejects Nix's fetcher; upstream
  # development now lives on the Tangled knot at knot.cl.cam.ac.uk.
  src = fetchgit {
    url = "https://knot.cl.cam.ac.uk/jonmsterling.com/ocaml-forester";
    rev = commit;
    hash = "sha256-dmwfNVLlZaKo5e8khzObPo1t1eNVExnhpHJnV1255kI=";
  };

  strictDeps = true;

  patches = [
    ./cmdliner-env-shadow.patch
  ];

  postPatch = ''
    # eio 1.7 added an optional ?config argument to Eio_main.run, which
    # prevents passing Eio_main.run directly to `let@`.
    for f in $(grep -rl 'let@ env = Eio_main.run in' bin lib); do
      substituteInPlace "$f" \
        --replace-fail 'let@ env = Eio_main.run in' 'let@ env = (fun k -> Eio_main.run k) in'
    done
  '';

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
