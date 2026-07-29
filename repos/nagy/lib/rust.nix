{
  pkgs,
  lib ? pkgs.lib,
}:

rec {
  cargoCratesIoRegistryGit = pkgs.fetchFromGitHub {
    owner = "rust-lang";
    repo = "crates.io-index";
    rev = "b0be0971bd0fc1a9496da6e44e4391205f26445f";
    hash = "sha256-mOBKMzftjO6MpGsYqec4nakDJwP1ci0Jb3k2dHQ1t2g=";
  };

  cargoConfigWithLocalRegistry = pkgs.linkFarm "cargo-home" {
    "config.toml" = pkgs.writers.writeTOML "config.toml" {
      source.crates-io = {
        replace-with = "local-copy";
      };
      source.local-copy = {
        local-registry = pkgs.linkFarm "crates.io-index" {
          index = cargoCratesIoRegistryGit;
        };
      };
    };
  };

  mkCargoLock =
    { file }:
    pkgs.runCommandLocal "Cargo.lock"
      {
        nativeBuildInputs = [ pkgs.cargo ];
        env = {
          CARGO_HOME = cargoConfigWithLocalRegistry;
          FILE = file;
        };
      }
      ''
        mkdir src
        ln -s -- "$FILE" Cargo.toml
        touch src/main.rs
        cargo generate-lockfile
        cp -- Cargo.lock $out
      '';

  mkCargoDoc =
    {
      name,
      version ? "*",
      extraNativeBuildInputs ? [ ],
    }:

    pkgs.stdenv.mkDerivation (finalAttrs: {
      name = "cargo-doc-${name}";

      src = pkgs.emptyDirectory;

      nativeBuildInputs = [
        pkgs.rustPlatform.cargoSetupHook
        pkgs.rustc
        pkgs.cargo
        pkgs.pkg-config # used by a lot of native library bindings
      ]
      ++ extraNativeBuildInputs;

      env = {
        CARGO_NET_OFFLINE = "1";
        __CARGO_TOML = pkgs.writers.writeTOML "Cargo.toml" {
          package = {
            name = "nix-build";
            version = "0.0.1";
            edition = "2024";
          };
          dependencies.${name} = {
            inherit version;
          };
        };
      };

      buildPhase = ''
        runHook preBuild

        ln -s -- $__CARGO_TOML Cargo.toml
        mkdir src
        touch src/main.rs
        cargo doc --package "${name}"

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mv target/doc $out

        runHook postInstall
      '';

      cargoDeps = pkgs.rustPlatform.importCargoLock {
        lockFile = mkCargoLock { file = "${finalAttrs.env.__CARGO_TOML}"; };
      };

      postPatch = ''
        ln -s $cargoDeps/Cargo.lock
      '';

      preferLocalBuild = true;
      allowSubstitutes = false;
    });

  mkRustScriptCargoToml =
    { file }:
    pkgs.runCommandLocal "Cargo.toml"
      {
        nativeBuildInputs = [
          pkgs.rustc
          pkgs.cargo
          pkgs.rust-script
          pkgs.writableTmpDirAsHomeHook
        ];
      }
      ''
        cp -- "${file}" script.rs
        rust-script --pkg-path . -p script.rs
        sed -i -e 's,/build/script.rs,${file},' Cargo.toml
        cp -- Cargo.toml $out
      '';

  mkCratesIoSqlite =
    let
      buildSql = pkgs.writeText "build-crates-db.sql" ''
        PRAGMA journal_mode = OFF;
        PRAGMA synchronous = OFF;
        PRAGMA cache_size = -128000;

        --------------------------------------------------------------------
        -- Phase 1: Raw staging tables (all TEXT, for .import compatibility)
        --------------------------------------------------------------------

        CREATE TEMP TABLE raw_crates (
            created_at      TEXT,
            description     TEXT,
            documentation   TEXT,
            homepage        TEXT,
            id              TEXT,
            name            TEXT,
            repository      TEXT,
            trustpub_only   TEXT,
            updated_at      TEXT
        );
        CREATE TEMP TABLE raw_versions (
            id      TEXT,
            num     TEXT,
            license TEXT
        );
        CREATE TEMP TABLE raw_dv (
            crate_id    TEXT,
            version_id  TEXT
        );
        CREATE TEMP TABLE raw_deps (
            crate_id    TEXT,
            features    TEXT,
            id          TEXT,
            kind        TEXT,
            optional    TEXT,
            req         TEXT,
            target      TEXT,
            version_id  TEXT
        );
        CREATE TEMP TABLE raw_cd (
            crate_id    TEXT,
            downloads   TEXT
        );
        CREATE TEMP TABLE raw_categories (
            category    TEXT,
            description TEXT,
            id          TEXT,
            slug        TEXT
        );
        CREATE TEMP TABLE raw_keywords (
            id      TEXT,
            keyword TEXT
        );
        CREATE TEMP TABLE raw_cc (
            category_id TEXT,
            crate_id    TEXT
        );
        CREATE TEMP TABLE raw_ck (
            crate_id    TEXT,
            keyword_id  TEXT
        );

        --------------------------------------------------------------------
        -- Phase 2: Import CSVs via native sqlite3 .import (streaming C, fast)
        --------------------------------------------------------------------

        .import --csv --skip 1 csvs/crates.csv             raw_crates
        .import --csv --skip 1 csvs/versions.csv            raw_versions
        .import --csv --skip 1 csvs/default_versions.csv    raw_dv
        .import --csv --skip 1 csvs/dependencies.csv        raw_deps
        .import --csv --skip 1 csvs/crate_downloads.csv     raw_cd
        .import --csv --skip 1 csvs/categories.csv          raw_categories
        .import --csv --skip 1 csvs/keywords.csv            raw_keywords
        .import --csv --skip 1 csvs/crates_categories.csv   raw_cc
        .import --csv --skip 1 csvs/crates_keywords.csv     raw_ck

        --------------------------------------------------------------------
        -- Phase 3: Final STRICT tables
        --------------------------------------------------------------------

        CREATE TABLE crates (
            name            TEXT PRIMARY KEY,
            display_name    TEXT NOT NULL,
            description     TEXT,
            documentation   TEXT,
            homepage        TEXT,
            repository      TEXT,
            created_at      TEXT,
            updated_at      TEXT,
            latest_version  TEXT,
            license         TEXT,
            downloads       INTEGER NOT NULL DEFAULT 0,
            trustpub_only   INTEGER NOT NULL DEFAULT 0
        ) STRICT, WITHOUT ROWID;

        CREATE TABLE categories (
            id          INTEGER PRIMARY KEY,
            category    TEXT NOT NULL,
            slug        TEXT NOT NULL,
            description TEXT
        ) STRICT;

        CREATE TABLE keywords (
            id      INTEGER PRIMARY KEY,
            keyword TEXT NOT NULL
        ) STRICT;

        CREATE TABLE crate_categories (
            crate_name  TEXT NOT NULL,
            category_id INTEGER NOT NULL,
            PRIMARY KEY (crate_name, category_id)
        ) STRICT;

        CREATE TABLE crate_keywords (
            crate_name TEXT NOT NULL,
            keyword_id INTEGER NOT NULL,
            PRIMARY KEY (crate_name, keyword_id)
        ) STRICT;

        CREATE TABLE dependencies (
            id          INTEGER PRIMARY KEY,
            crate_name  TEXT NOT NULL,
            dep_name    TEXT NOT NULL,
            req         TEXT NOT NULL,
            kind        TEXT NOT NULL DEFAULT 'normal',
            optional    INTEGER NOT NULL DEFAULT 0,
            features    TEXT,
            target      TEXT
        ) STRICT;

        --------------------------------------------------------------------
        -- Phase 4: Build integer-keyed lookup maps
        --------------------------------------------------------------------

        CREATE TEMP TABLE crate_id_map (
            crate_id INTEGER PRIMARY KEY,
            name     TEXT NOT NULL
        ) STRICT;
        INSERT INTO crate_id_map (crate_id, name)
        SELECT CAST(rc.id AS INTEGER),
               lower(replace(rc.name, '-', '_'))
        FROM raw_crates rc
        WHERE rc.name IS NOT NULL AND rc.name != ''';

        -- Only default versions (so we can filter dependencies later)
        CREATE TEMP TABLE dv_lookup (
            version_id INTEGER PRIMARY KEY,
            crate_id   INTEGER NOT NULL
        ) STRICT;
        INSERT INTO dv_lookup (version_id, crate_id)
        SELECT CAST(rdv.version_id AS INTEGER),
               CAST(rdv.crate_id AS INTEGER)
        FROM raw_dv rdv;

        --------------------------------------------------------------------
        -- Phase 5: Populate final tables
        --------------------------------------------------------------------

        INSERT INTO crates (name, display_name, description, documentation,
                            homepage, repository, created_at, updated_at,
                            latest_version, license, downloads, trustpub_only)
        SELECT
            lower(replace(rc.name, '-', '_')),
            rc.name,
            NULLIF(rc.description, '''),
            NULLIF(rc.documentation, '''),
            NULLIF(rc.homepage, '''),
            NULLIF(rc.repository, '''),
            rc.created_at,
            rc.updated_at,
            rv.num,
            rv.license,
            COALESCE(CAST(rcd.downloads AS INTEGER), 0),
            CASE rc.trustpub_only WHEN 't' THEN 1 ELSE 0 END
        FROM raw_crates rc
        LEFT JOIN raw_dv rdv ON rc.id = rdv.crate_id
        LEFT JOIN raw_versions rv ON rdv.version_id = rv.id
        LEFT JOIN raw_cd rcd ON rc.id = rcd.crate_id
        WHERE rc.name IS NOT NULL AND rc.name != ''';

        INSERT INTO categories (id, category, slug, description)
        SELECT CAST(id AS INTEGER), category, slug,
               NULLIF(description, ''')
        FROM raw_categories;

        INSERT INTO keywords (id, keyword)
        SELECT CAST(id AS INTEGER), keyword
        FROM raw_keywords;

        INSERT INTO crate_categories (crate_name, category_id)
        SELECT cim.name, CAST(raw_cc.category_id AS INTEGER)
        FROM raw_cc
        JOIN crate_id_map cim ON CAST(raw_cc.crate_id AS INTEGER) = cim.crate_id;

        INSERT INTO crate_keywords (crate_name, keyword_id)
        SELECT cim.name, CAST(raw_ck.keyword_id AS INTEGER)
        FROM raw_ck
        JOIN crate_id_map cim ON CAST(raw_ck.crate_id AS INTEGER) = cim.crate_id;

        INSERT INTO dependencies (crate_name, dep_name, req, kind,
                                  optional, features, target)
        SELECT
            own.name,
            COALESCE(dep.name, rd.crate_id),
            rd.req,
            CASE rd.kind
                WHEN '0' THEN 'normal'
                WHEN '1' THEN 'build'
                WHEN '2' THEN 'dev'
                ELSE rd.kind
            END,
            CASE rd.optional WHEN 't' THEN 1 ELSE 0 END,
            NULLIF(TRIM(rd.features, '{}'), '''),
            NULLIF(rd.target, ''')
        FROM raw_deps rd
        JOIN dv_lookup dvl ON CAST(rd.version_id AS INTEGER) = dvl.version_id
        JOIN crate_id_map own ON dvl.crate_id = own.crate_id
        LEFT JOIN crate_id_map dep ON CAST(rd.crate_id AS INTEGER) = dep.crate_id;

        ---------------------------------------------------------------
        -- Phase 6: Indexes
        ---------------------------------------------------------------

        CREATE INDEX idx_deps_crate ON dependencies(crate_name);
        CREATE INDEX idx_deps_dep   ON dependencies(dep_name);
        CREATE INDEX idx_cc_cat     ON crate_categories(category_id);
        CREATE INDEX idx_ck_keyword ON crate_keywords(keyword_id);

        ---------------------------------------------------------------
        -- Phase 7: Compact
        ---------------------------------------------------------------

        VACUUM;
      '';
    in
    {
      /*
        This should point to a local copy of https://static.crates.io/db-dump.tar.gz .
        e.g.
        `toString /path/to/static.crates.io/db-dump.tar.gz`
      */
      file,
    }:
    pkgs.runCommandLocal "crates-io.db"
      {
        nativeBuildInputs = [
          pkgs.sqlite
          pkgs.csvkit
        ];
      }
      ''
        mkdir csvs

        tar -xOf "${file}" --wildcards '*/data/crates.csv' \
          | csvcut --maxfieldsize $((5*1024*1024)) \
              -c created_at,description,documentation,homepage,id,name,repository,trustpub_only,updated_at \
          > csvs/crates.csv

        tar -xOf "${file}" --wildcards '*/data/versions.csv' \
          | csvcut --maxfieldsize $((5*1024*1024)) \
              -c id,num,license \
          > csvs/versions.csv

        tar -xOf "${file}" --wildcards '*/data/default_versions.csv' \
          | csvcut -c crate_id,version_id \
          > csvs/default_versions.csv

        tar -xOf "${file}" --wildcards '*/data/dependencies.csv' \
          | csvcut -c crate_id,features,id,kind,optional,req,target,version_id \
          > csvs/dependencies.csv

        tar -xOf "${file}" --wildcards '*/data/crate_downloads.csv' \
          > csvs/crate_downloads.csv

        tar -xOf "${file}" --wildcards '*/data/categories.csv' \
          | csvcut -c category,description,id,slug \
          > csvs/categories.csv

        tar -xOf "${file}" --wildcards '*/data/keywords.csv' \
          | csvcut -c id,keyword \
          > csvs/keywords.csv

        tar -xOf "${file}" --wildcards '*/data/crates_categories.csv' \
          > csvs/crates_categories.csv

        tar -xOf "${file}" --wildcards '*/data/crates_keywords.csv' \
          > csvs/crates_keywords.csv

        sqlite3 $out < ${buildSql}
      '';

  importRust = {
    check = lib.hasSuffix ".rs";
    __functor =
      _self: file:
      let
        tomlString = lib.pipe file [
          (it: mkRustScriptCargoToml { file = it; })
          lib.readFile
          lib.unsafeDiscardStringContext
        ];
        selfTOML = lib.fromTOML tomlString;
      in
      selfTOML
      //
        # To repair the string context.
        {
          bin = [
            {
              name = selfTOML.package.name;
              path = "${file}";
            }
          ];
        };
  };

}
