{ lib }:
rec {
  /**
    Reads the fetchrix output directory `dir` into
    `{ <name> = { pname; version; rawVersion; src; <derived>...; }; }`; `pname` defaults
    to `<name>`.

    A derived hash becomes its SRI string. An extracted `Cargo.lock` becomes
    `{ lockFile; outputHashes; }`, which `cargoLock` accepts directly. An
    extracted `package-lock.json` becomes `{ npmRoot; package; packageLock; }`,
    the arguments of `importNpmLock`; `npmRoot` points into `src` so local and
    workspace dependencies resolve against the fetched source. Files exported
    by `prepare` become paths in `artifacts`, keyed by name.

    With the fetchrix configuration file `config`, a `fod` derived hash that
    is declared there but not locked yet is `lib.fakeHash`, so the package
    still evaluates while fetchrix computes the hash for the first time.
  */
  load =
    {
      pkgs,
      dir,
      config ? null,
    }:
    let
      parsed = lib.importJSON (dir + "/lock.json");
      declared = if config == null then { } else (lib.importTOML config).packages or { };

      unlocked =
        name:
        lib.mapAttrs (_: _: lib.fakeHash) (
          lib.filterAttrs (_: spec: spec.strategy == "fod") (declared.${name}.derive or { })
        );

      fetchSrc =
        src:
        let
          args = removeAttrs src [ "fetcher" ];
        in
        {
          url = pkgs.fetchurl args;
          tarball = pkgs.fetchzip args;
          github = pkgs.fetchFromGitHub args;
          # fetchgit fetches submodules by default; the lock omits `false`.
          git = pkgs.fetchgit ({ fetchSubmodules = false; } // args);
        }
        .${src.fetcher} or (throw "fetchrix: unknown fetcher `${src.fetcher}`");

      derive =
        name: src: entry:
        if entry ? hash then
          entry.hash
        else
          let
            lockFile = dir + "/${entry.lockfile}";
            inSource = lib.removePrefix "${name}/src/" entry.lockfile;
            subDir = dirOf inSource;
          in
          {
            "Cargo.lock" = {
              inherit lockFile;
              outputHashes = entry.outputHashes or { };
            };
            "package-lock.json" = {
              npmRoot = if subDir == "." then src else "${src}/${subDir}";
              package = lib.importJSON (dirOf lockFile + "/package.json");
              packageLock = lib.importJSON lockFile;
            };
          }
          .${baseNameOf inSource} or (throw "fetchrix: unknown lock file `${entry.lockfile}`");
    in
    assert lib.assertMsg (
      parsed.schema == 1
    ) "fetchrix: unsupported lock schema ${toString parsed.schema}";
    lib.mapAttrs (
      name: pkg:
      let
        src = fetchSrc pkg.src;
      in
      {
        pname = pkg.pname or name;
        inherit (pkg) version rawVersion;
      }
      // lib.optionalAttrs (pkg ? date) { inherit (pkg) date; }
      // {
        inherit src;
      }
      // lib.optionalAttrs (pkg ? artifacts) {
        artifacts = lib.mapAttrs (_: path: dir + "/${path}") pkg.artifacts;
      }
      // unlocked name
      // lib.mapAttrs (_: derive name src) (pkg.derived or { })
    ) parsed.packages;

  /**
    Overlay that exposes `load { dir; config; }` as `pkgs.<attr>`, using the
    fetchers of the final package set.
  */
  overlay =
    {
      dir,
      config ? null,
      attr ? "sources",
    }:
    final: _prev: {
      ${attr} = load {
        pkgs = final;
        inherit dir config;
      };
    };
}
