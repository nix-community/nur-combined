{
  lib,
  fetchgit,
  fetchFromGitHub,
  nix-update-script,
  writeShellApplication,
  nixpkgs_pkgs,
  pcre2,
  gmp,
  libev,
  tree-sitter,
}:

let
  # Upstream builds with OCaml 5.5; the repository-wide ocamlPackages overlay is
  # 5.4 and marks memprof-limits broken there. The three development forks are
  # the ones semgrep.opam pins: released memprof-limits is broken on OCaml 5,
  # memtrace's released version predates the compatibility work, and semgrep
  # relies on the full-arity visitors code generator.
  ocamlPackages = nixpkgs_pkgs.ocamlPackages.overrideScope (
    _: osuper: {
      memprof-limits = osuper.memprof-limits.overrideAttrs (old: {
        version = "0.2.1-unstable-2025-02-05";
        src = fetchgit {
          url = "https://gitlab.com/dimitris-m/memprof-limits.git";
          rev = "c2cced325a93d2271379f0712db85867b29dbee1";
          hash = "sha256-oY/ElDhsL+wfz9MpwqO/rwvHt3wOeKly0BYcR4ckAYQ=";
        };
        meta = (old.meta or { }) // {
          broken = false;
        };
      });
      memtrace = osuper.memtrace.overrideAttrs (_: {
        version = "0.2.3-unstable-2026-09-17";
        src = fetchgit {
          url = "https://github.com/opengrep/memtrace.git";
          rev = "874e70b283cf8bd7734d5c598dc176d0eb2547f3";
          hash = "sha256-dsV+2bnDDhGZ9QSqBJUKz1c5d5e92IQYOBDhg9M6sMg=";
        };
      });
      visitors = osuper.visitors.overrideAttrs (_: {
        version = "0-unstable-2026-10-13";
        src = fetchgit {
          url = "https://github.com/opengrep/visitors.git";
          rev = "e18a7a67150a54a3aef51661e0317cacc313d764";
          hash = "sha256-AdZEzMt20IVqW1PVPxfBHh2LigYP0/Eh17aElK0GDO4=";
        };
      });
    }
  );
  inherit (ocamlPackages) buildDunePackage;

  # Not packaged in nixpkgs; both are direct dependencies of opengrep.
  sarif = buildDunePackage rec {
    pname = "sarif";
    version = "0.3.1";

    src = fetchFromGitHub {
      owner = "gborough";
      repo = "sarif";
      tag = version;
      hash = "sha256-nqs7dqI7zD9IcViEsVYZTQIvXl4EtR5b6Xxam4VpI48=";
    };

    # lib/dune generates its modules with the atdgen executable.
    nativeBuildInputs = [ ocamlPackages.atdgen ];

    propagatedBuildInputs = with ocamlPackages; [
      atdgen
      atdgen-runtime
      ppx_deriving
      re
      timedesc
      uri
    ];

    meta = {
      description = "Static Analysis Results Interchange Format (SARIF) 2.1.0";
      homepage = "https://github.com/gborough/sarif";
      license = lib.licenses.mit;
    };
  };

  thread-local-storage = buildDunePackage rec {
    pname = "thread-local-storage";
    version = "0.2";

    src = fetchFromGitHub {
      owner = "c-cube";
      repo = "thread-local-storage";
      tag = "v${version}";
      hash = "sha256-ijswqxFx4IsWpU+KJ+0xZJLvPisVXp+TWturBIidPBQ=";
    };

    meta = {
      description = "Efficient thread local storage for OCaml";
      homepage = "https://github.com/c-cube/thread-local-storage";
      license = lib.licenses.mit;
    };
  };
in
buildDunePackage rec {
  pname = "opengrep";
  version = "2.1.0";

  # The language grammars (languages/*/tree-sitter/*) and
  # libs/ocaml-tree-sitter-core are git submodules; dune compiles all of them.
  src = fetchFromGitHub {
    owner = "opengrep";
    repo = "opengrep";
    tag = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-oLZ62bBOui/mZLo7DBSXxkwFkwOffxvqjs4T8gOjz9E=";
  };

  # flags.sh tries to statically link against Homebrew paths on macOS; this is
  # the documented switch that makes it emit plain autolinked flags instead.
  env.SEMGREP_NIX_BUILD = "1";

  # dune executes this helper by its relative path; its /usr/bin/env shebang
  # does not resolve in the sandbox.
  postPatch = ''
    patchShebangs src/main/flags.sh src/main/list-tree-sitter-langs.sh
  '';

  nativeBuildInputs = with ocamlPackages; [
    atdgen
    menhir
  ];

  buildInputs = [
    pcre2
    gmp
    libev
    tree-sitter
  ];

  propagatedBuildInputs = with ocamlPackages; [
    alcotest
    alcotest-lwt
    ansiterminal
    atdgen
    base
    bos
    calendar
    cmdliner
    cohttp
    cohttp-lwt-unix
    digestif
    domainslib
    dune-build-info
    dune-configurator
    emile
    fileutils
    fmt
    fpath
    git
    logs
    lsp
    lwt
    lwt_ppx
    memprof-limits
    memtrace
    # 2.1.0 uses the mtime.clock sublibrary
    mtime
    ocolor
    ocamlgraph
    otoml
    ppx_assert
    ppx_deriving
    ppx_deriving_yojson
    ppx_expect
    ppx_hash
    ppx_inline_test
    ppx_sexp_conv
    ppxlib
    re
    sarif
    saturn
    semver
    sexplib
    terminal_size
    thread-local-storage
    timedesc
    tsort
    tls-lwt
    tls-mirage
    uri
    uuidm
    uucp
    uutf
    visitors
    xmlm
    yaml
    yojson
  ];

  # Like `make core`: build only the engine binary, not the test/dev binaries.
  buildPhase = ''
    runHook preBuild
    dune build -j$NIX_BUILD_CORES _build/install/default/bin/opengrep
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 _build/install/default/bin/opengrep $out/bin/opengrep
    runHook postInstall
  '';

  # Only the engine binary is installed; skip buildDunePackage's empty
  # man/doc outputs.
  outputs = [ "out" ];

  doCheck = false;

  passthru.updateScript = writeShellApplication {
    name = "update-opengrep";
    text = ''
      export UPDATE_NIX_ATTR_PATH="opengrep"
      exec ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [
            "--version-regex"
            "v(.*)"
          ];
        })
      } "$@"
    '';
  };

  meta = {
    description = "Static analysis engine to find security issues in code";
    homepage = "https://opengrep.dev";
    license = lib.licenses.lgpl21Only;
    mainProgram = "opengrep";
    platforms = lib.platforms.unix;
  };
}
