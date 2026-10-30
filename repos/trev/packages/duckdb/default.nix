{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  callPackage,
  cmake,
  lndir,
  makeWrapper,
  ninja,
  pkg-config,
  openssl,
  openjdk11,
  python3,
  unixodbc,
  versionCheckHook,

  # extensions
  withAutocomplete ? true,
  withIcu ? true,
  withJson ? true,
  withTpcds ? true,
  withTpch ? true,

  # out-of-tree extensions
  withAvro ? false,
  withAws ? false,
  withAzure ? false,
  withDucklake ? false,
  withEncodings ? false,
  withExcel ? false,
  withFts ? false,
  withHttpfs ? false,
  withIceberg ? false,
  withInet ? false,
  withMysqlScanner ? false,
  withOdbcScanner ? false,
  withPostgresScanner ? false,
  withQuack ? false,
  withSpatial ? false,
  withSqliteScanner ? false,
  withSqlsmith ? false,
  withVss ? false,

  # drivers
  withJdbc ? false,
  withOdbc ? false,
}:

let
  canRunHostBinaries = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  duckdbPlatform =
    let
      os =
        if stdenv.hostPlatform.isLinux then
          "linux"
        else if stdenv.hostPlatform.isDarwin then
          "osx"
        else if stdenv.hostPlatform.isWindows then
          "windows"
        else if stdenv.hostPlatform.isFreeBSD then
          "freebsd"
        else
          throw "Unsupported DuckDB platform OS: ${stdenv.hostPlatform.config}";
      arch =
        if stdenv.hostPlatform.isx86_64 then
          "amd64"
        else if stdenv.hostPlatform.isAarch64 then
          "arm64"
        else if stdenv.hostPlatform.isi686 then
          "i686"
        else
          throw "Unsupported DuckDB platform architecture: ${stdenv.hostPlatform.config}";
      postfix =
        if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isMusl then
          "_musl"
        else if stdenv.hostPlatform.isAndroid then
          "_android"
        else if stdenv.hostPlatform.isMinGW then
          "_mingw"
        else
          "";
    in
    "${os}_${arch}${postfix}";

  mkExtension = name: {
    inherit name;
    loadOptions = [ ];
  };
  inTreeExtensions = map mkExtension (
    lib.optionals withAutocomplete [ "autocomplete" ]
    ++ lib.optionals withTpcds [ "tpcds" ]
    ++ lib.optionals withTpch [ "tpch" ]
  );

  extensions = callPackage ./extensions { };
  # include the extensions each enabled extension loads, dependencies first
  withDependencies =
    drvs:
    lib.unique (
      lib.concatMap (
        drv:
        withDependencies (map (name: extensions.${name}) drv.passthru.duckdbExtension.dependencies)
        ++ [ drv ]
      ) drvs
    );
  externalExtensionDrvs = withDependencies (
    lib.optionals withAvro [ extensions.avro ]
    ++ lib.optionals withAws [ extensions.aws ]
    ++ lib.optionals withAzure [ extensions.azure ]
    ++ lib.optionals withDucklake [ extensions.ducklake ]
    ++ lib.optionals withEncodings [ extensions.encodings ]
    ++ lib.optionals withExcel [ extensions.excel ]
    ++ lib.optionals withFts [ extensions.fts ]
    ++ lib.optionals withHttpfs [ extensions.httpfs ]
    ++ lib.optionals withIceberg [ extensions.iceberg ]
    ++ lib.optionals withInet [ extensions.inet ]
    ++ lib.optionals withMysqlScanner [ extensions.mysql-scanner ]
    ++ lib.optionals withOdbcScanner [ extensions.odbc-scanner ]
    ++ lib.optionals withPostgresScanner [ extensions.postgres-scanner ]
    ++ lib.optionals withQuack [ extensions.quack ]
    ++ lib.optionals withSpatial [ extensions.spatial ]
    ++ lib.optionals withSqliteScanner [ extensions.sqlite-scanner ]
    ++ lib.optionals withSqlsmith [ extensions.sqlsmith ]
    ++ lib.optionals withVss [ extensions.vss ]
  );

  externalExtensions = map (
    extension:
    lib.throwIf (stdenv.hostPlatform.isStatic && !extension.passthru.duckdbExtension.linkable)
      "duckdb: ${extension.passthru.duckdbExtension.name} can only be loaded at runtime, which static builds do not support"
      extension.passthru.duckdbExtension
    // {
      src = extension;
    }
  ) externalExtensionDrvs;

  # out-of-tree extensions are built separately as loadable extensions against a prebuilt duckdb,
  # except in static builds, which cannot load extensions at runtime and link everything in
  linkedExtensions = lib.optionals stdenv.hostPlatform.isStatic externalExtensions;
  loadableExtensions = lib.optionals (!stdenv.hostPlatform.isStatic) externalExtensions;

  # extension/extension_config.cmake always builds and links these, so disabling one skips it
  skippedExtensions = lib.optionals (!withIcu) [ "icu" ] ++ lib.optionals (!withJson) [ "json" ];

  # system libraries of linked extensions, resolved at build time for passthru.link.static
  pkgConfigModules = lib.unique (
    lib.concatMap (extension: extension.pkgConfigModules) linkedExtensions
  );
  systemLibrariesFile = "nix-support/duckdb-static-ldflags";
  # the generated loader and its autoregistration, pulled from the archive by staticExtensionLoaderSymbol
  staticExtensionLoaderArchive = "libduckdb_static_extension_loader.a";
  staticExtensionLoaderSymbol = "duckdb_static_extension_autoregister";
  # linked and registered like extensions, see duckdb_resolve_static_link
  capabilities = [
    "httplib"
    "loadable_extensions"
  ];

  # extensions are only built as loadable extensions unless they are also statically linked
  formatExtensionLoad =
    link: extension:
    (
      if extension.loadOptions == [ ] then
        "duckdb_extension_load(${extension.name})"
      else
        lib.concatStringsSep "\n" (
          [ "duckdb_extension_load(${extension.name}" ]
          ++ map (option: "    ${option}") extension.loadOptions
          ++ [ ")" ]
        )
    )
    + lib.optionalString link "\nduckdb_extension_statically_link(${extension.name})";

  externalExtensionCopyCommand =
    extension:
    let
      destination = "extension_external/${extension.name}";
      # the patches duckdb applies to the extension commit it pins, applied the same way as scripts/apply_extension_patches.py
      upstreamPatches = ".github/patches/extensions/${extension.name}";
    in
    ''
      cp -R ${lib.escapeShellArg (toString extension.src)} ${lib.escapeShellArg destination}
      chmod -R u+w ${lib.escapeShellArg destination}
      if [ -d ${lib.escapeShellArg upstreamPatches} ]; then
        for patch in ${lib.escapeShellArg upstreamPatches}/*.patch; do
          patch -d ${lib.escapeShellArg destination} -p1 --forward -i "$PWD/$patch"
        done
      fi
    '';

  mkPostPatch =
    link: extensions: externalExtensions:
    lib.optionalString (extensions != [ ]) ''
      ${lib.optionalString (externalExtensions != [ ]) ''
        mkdir -p extension_external
        ${lib.concatMapStringsSep "\n" externalExtensionCopyCommand externalExtensions}
      ''}

      ${lib.concatMapStringsSep "\n" (extension: extension.duckdbPostPatch) externalExtensions}

      cat >> extension/extension_config.cmake <<'EOF'

      ${lib.concatMapStringsSep "\n" (formatExtensionLoad link) extensions}
      EOF
    '';

  mkLoadableExtension =
    duckdb: extension:
    stdenv.mkDerivation {
      pname = "duckdb-loadable-${extension.name}";
      inherit (duckdb) version src patches;

      nativeBuildInputs = [
        cmake
        ninja
        python3
      ]
      ++ extension.duckdbNativeBuildInputs;
      buildInputs = [ openssl ] ++ extension.duckdbBuildInputs;

      postPatch = mkPostPatch false [ extension ] [ extension ];

      cmakeFlags = [
        (lib.cmakeFeature "PREBUILT_BINARY" "${duckdb.lib}/lib/libduckdb_static.a")
        (lib.cmakeBool "BUILD_SHELL" false)
        (lib.cmakeBool "BUILD_UNITTESTS" false)
        (lib.cmakeFeature "OVERRIDE_GIT_DESCRIBE" "v${duckdb.version}")
      ]
      ++ lib.optionals (!canRunHostBinaries) [
        (lib.cmakeFeature "DUCKDB_EXPLICIT_PLATFORM" duckdbPlatform)
      ];

      ninjaFlags = [ extension.loadableTarget ];

      installPhase = ''
        runHook preInstall

        install -Dm444 extension/${extension.name}/${extension.name}.duckdb_extension \
          -t "$out/share/duckdb/extensions/v${duckdb.version}/${duckdbPlatform}"

        runHook postInstall
      '';

      meta = duckdb.meta // {
        description = "DuckDB ${extension.name} extension";
      };
    };

  # duckdb with loadable extensions available through DUCKDB_NIX_EXTENSION_DIRECTORIES
  withLoadableExtensions =
    duckdb:
    if loadableExtensions == [ ] then
      duckdb
    else
      stdenvNoCC.mkDerivation (finalAttrs: {
        inherit (duckdb) pname version outputs;

        nativeBuildInputs = [
          lndir
          makeWrapper
        ];

        buildCommand = ''
          mkdir -p "$out" "$lib" "$dev"
          lndir -silent ${duckdb.out} "$out"
          lndir -silent ${duckdb.lib} "$lib"
          lndir -silent ${duckdb.dev} "$dev"
          for extension in ${lib.escapeShellArgs finalAttrs.passthru.loadableExtensions}; do
            lndir -silent "$extension" "$out"
          done

          rm "$out/bin/duckdb"
          makeWrapper ${lib.getExe duckdb} "$out/bin/duckdb" \
            --prefix DUCKDB_NIX_EXTENSION_DIRECTORIES : "$out/share/duckdb/extensions"
        ''
        + lib.optionalString canRunHostBinaries ''
          for extension in ${lib.escapeShellArgs (map (extension: extension.name) loadableExtensions)}; do
            HOME="$(mktemp -d)" "$out/bin/duckdb" -c "LOAD $extension"
          done
        '';

        passthru = duckdb.passthru // {
          unwrapped = duckdb;
          loadableExtensions = map (mkLoadableExtension duckdb) loadableExtensions;
          extensionDirectory = "${finalAttrs.finalPackage}/share/duckdb/extensions";
        };

        inherit (duckdb) meta;
      });
in
withLoadableExtensions (
  stdenv.mkDerivation (finalAttrs: {
    pname = "duckdb";
    version = "2.0.0";

    src = fetchFromGitHub {
      owner = "duckdb";
      repo = "duckdb";
      tag = "v${finalAttrs.version}";
      hash = "sha256-1fhgPD/QGT/fK+BabX2dbTWOsajS6feNl5+9iw8rvwU=";
    };

    outputs = [
      "out"
      "lib"
      "dev"
    ];

    nativeBuildInputs = [
      cmake
      ninja
      python3
    ]
    ++ lib.concatMap (extension: extension.duckdbNativeBuildInputs) linkedExtensions
    ++ lib.optionals (pkgConfigModules != [ ]) [ pkg-config ];
    buildInputs = [
      openssl
    ]
    ++ lib.concatMap (extension: extension.duckdbBuildInputs) linkedExtensions
    ++ lib.optionals withJdbc [ openjdk11 ]
    ++ lib.optionals withOdbc [ unixodbc ];

    patches = [
      ./nix-extension-directories.patch
    ]
    ++ lib.optionals stdenv.hostPlatform.isStatic [
      ./static-no-loadable-extensions.patch
    ];

    postPatch = mkPostPatch true (inTreeExtensions ++ linkedExtensions) linkedExtensions;

    # programs linking libduckdb_static.a register its extensions through a generated loader, see passthru.link.static
    postInstall = ''
      python3 ../scripts/generate_static_extension_loader.py -o static_extension_loader.c \
        ${lib.escapeShellArgs finalAttrs.passthru.link.static.registeredExtensions}
      "$CC" -c -O2 -fPIC -I"$dev/include" static_extension_loader.c -o static_extension_loader.o
      # the autoregistration only has a constructor, so give it a symbol the linker can be told to keep
      printf '%s\n' '#include "static_extension_autoregister.cpp"' \
        'extern "C" const int ${staticExtensionLoaderSymbol} = 0;' > static_extension_autoregister_symbol.cpp
      "$CXX" -c -O2 -fPIC -I../extension/loader static_extension_autoregister_symbol.cpp \
        -o static_extension_autoregister.o
      # an archive, unlike objects, can be named repeatedly, as Go does with CGO_LDFLAGS for each cgo package
      "$AR" rcs "$lib/lib/${staticExtensionLoaderArchive}" static_extension_loader.o static_extension_autoregister.o
    ''
    + lib.optionalString (pkgConfigModules != [ ]) ''
      mkdir -p "$dev/${builtins.dirOf systemLibrariesFile}"
      "$PKG_CONFIG" --static --libs ${lib.escapeShellArgs pkgConfigModules} > "$dev/${systemLibrariesFile}"
    '';

    cmakeFlags = [
      (lib.cmakeBool "BUILD_ODBC_DRIVER" withOdbc)
      # without local_extension_repository, which points automatic installs at the build directory
      (lib.cmakeFeature "DUCKDB_CAPABILITIES" (lib.concatStringsSep ";" capabilities))
      (lib.cmakeBool "ENABLE_EXTENSION_AUTOLOADING" true)
      (lib.cmakeBool "JDBC_DRIVER" withJdbc)
      (lib.cmakeBool "NIX_STATIC_BUILD" stdenv.hostPlatform.isStatic)
      (lib.cmakeFeature "OVERRIDE_GIT_DESCRIBE" "v${finalAttrs.version}")
      # development settings
      (lib.cmakeBool "BUILD_UNITTESTS" finalAttrs.doInstallCheck)
    ]
    ++ lib.optionals (skippedExtensions != [ ]) [
      (lib.cmakeFeature "SKIP_EXTENSIONS" (lib.concatStringsSep ";" skippedExtensions))
    ]
    ++ lib.optionals (lib.any (extension: extension.name == "spatial") linkedExtensions) [
      # Match spatial's dependencies to avoid mixing C++11 and C++17 constexpr symbols.
      (lib.cmakeFeature "CMAKE_CXX_STANDARD" "17")
    ]
    ++ lib.optionals (!canRunHostBinaries) [
      (lib.cmakeFeature "DUCKDB_EXPLICIT_PLATFORM" duckdbPlatform)
    ];

    doInstallCheck = canRunHostBinaries;
    nativeInstallCheckInputs = [ versionCheckHook ];
    installCheckPhase =
      let
        excludes = map (pattern: "exclude:'${pattern}'") (
          [
            "[s3]"
            "Test closing database during long running query"
            "Test using a remote optimizer pass in case thats important to someone"
            "test/common/test_cast_hugeint.test"
            "test/sql/copy/csv/test_csv_remote.test"
            "test/sql/copy/parquet/test_parquet_remote.test"
            "test/sql/copy/parquet/test_parquet_remote_foreign_files.test"
            "test/sql/storage/compression/chimp/chimp_read.test"
            "test/sql/storage/compression/chimp/chimp_read_float.test"
            "test/sql/storage/compression/patas/patas_compression_ratio.test_coverage"
            "test/sql/storage/compression/patas/patas_read.test"
            "test/sql/json/read_json_objects.test"
            "test/sql/json/read_json.test"
            "test/sql/json/table/read_json_objects.test"
            "test/sql/json/table/read_json.test"
            "test/sql/copy/parquet/parquet_5968.test"
            "test/fuzzer/pedro/buffer_manager_out_of_memory.test"
            "test/sql/storage/compression/bitpacking/bitpacking_size_calculation.test"
            "test/sql/copy/parquet/delta_byte_array_length_mismatch.test"
            "test/sql/function/timestamp/test_icu_strptime.test"
            "test/sql/timezone/test_icu_timezone.test"
            "test/sql/copy/parquet/snowflake_lineitem.test"
            "test/sql/copy/parquet/test_parquet_force_download.test"
            "test/sql/copy/parquet/delta_byte_array_multiple_pages.test"
            "test/sql/copy/csv/test_csv_httpfs_prepared.test"
            "test/sql/copy/csv/test_csv_httpfs.test"
            "test/sql/settings/test_disabled_file_system_httpfs.test"
            "test/sql/copy/csv/parallel/test_parallel_csv.test"
            "test/sql/copy/csv/parallel/csv_parallel_httpfs.test"
            "test/common/test_cast_struct.test"
            # test is order sensitive
            "test/sql/copy/parquet/parquet_glob.test"
            # these are only hidden if no filters are passed in
            "[!hide]"
            # this test apparently never terminates
            "test/sql/copy/csv/auto/test_csv_auto.test"
            # test expects installed file timestamp to be > 2024
            "test/sql/table_function/read_text_and_blob.test"
            # fails with Out of Memory Error
            "test/sql/copy/parquet/batched_write/batch_memory_usage.test"
            # fails on x86_64-linux as well as aarch64
            "test/sql/settings/operator_memory_limit.test"
            "test/sql/storage/test_eviction_queue_dead_nodes_underflow.test"
            # wants http connection
            "test/sql/copy/csv/recursive_query_csv.test"
            "test/sql/copy/csv/test_mixed_lines.test"
            "test/parquet/parquet_long_string_stats.test"
            "test/sql/attach/attach_remote.test"
            "test/sql/attach/attach_remote_http_logging.test"
            "test/sql/attach/remote_file_concurrently.test"
            "test/sql/copy/csv/test_sniff_httpfs.test"
            "test/sql/httpfs/internal_issue_2490.test"
            "test/sql/logging/http_response_log_redaction.test"
            # fails with incorrect result
            # Upstream issue https://github.com/duckdb/duckdb/issues/14294
            "test/sql/copy/file_size_bytes.test"
            # https://github.com/duckdb/duckdb/issues/17757#issuecomment-3032080432
            "test/issues/general/test_17757.test"
          ]
          ++ lib.optionals stdenv.hostPlatform.isStatic [
            "Core extension downloads use managed HTTP transports"
            "test/extension/concurrent_load_extension.test"
            "test/extension/consistent_semicolon_extension_parse.test"
            "test/extension/load_extension.test"
            "test/extension/load_test_alias.test"
            "test/extension/loadable_parser_override.test"
            "test/extension/reset_global_extension_option.test"
            "test/extension/test_alias_point.test"
            "test/extension/test_custom_type_modifier_cast.test"
            "test/extension/test_loadable_optimizer.test"
            "test/extension/test_tags.test"
            "test/extension/update_extensions.test"
            "test/extension/explicit_extension_schema_testing.test"
            "test/extension/load_extension_capi_v2.test"
            "test/extension/local_extension_coverage.test"
            "test/extension/test_extensible_filter.test"
            "test/extension/test_function_args_kwargs.test"
            "test/extension/test_function_named_args.test"
            "test/extension/test_loadable_dialect_extension.test"
            "test/extension/test_loadable_grammar_extension.test"
            "test/extension/volatile_aggregate.test"
            "test/extension/window_extension.test"
            "test/sql/extensions/aliasing.test"
            "test/sql/extensions/load_use_extension_one_query.test"
            "test/sql/extensions/quack_peeling.test"
            # call quack_serve without requiring httpfs, which provides its crypto module
            "test/sql/attach/external_resource_lifecycle.test"
            "test/sql/attach/external_resource_logging.test"
            # the server-side Quack log entry for the forwarded CONNECT is missing; loadable builds
            # skip this test because quack is not linked into unittest
            "test/sql/connect/connect_passthrough_quack.test"
          ]
          ++ lib.optionals stdenv.hostPlatform.isAarch64 [
            "test/sql/aggregate/aggregates/test_kurtosis.test"
            "test/sql/aggregate/aggregates/test_skewness.test"
            "test/sql/function/list/aggregates/skewness.test"
            "test/sql/aggregate/aggregates/histogram_table_function.test"
          ]
          ++ lib.optionals stdenv.hostPlatform.isDarwin [
            # UB in PhysicalRangeJoin (shared by IEJoin and PiecewiseMergeJoin) causes
            # Apple Clang at -O3 to emit brk trap instructions on aarch64-darwin.
            # Affects any test routing through PhysicalIEJoin (2+ inequality conditions,
            # cardinality >= merge_join_threshold) or forcing IEJoin via debug_asof_iejoin.
            "test/sql/join/iejoin/iejoin_issue_6314.test_slow"
            "test/sql/join/iejoin/iejoin_issue_6861.test"
            "test/sql/join/iejoin/iejoin_issue_7278.test"
            "test/sql/join/iejoin/iejoin_projection_maps.test"
            "test/sql/join/iejoin/merge_join_switch.test"
            "test/sql/join/iejoin/predicate_expressions.test"
            "test/sql/join/iejoin/test_countzeros.test"
            "test/sql/join/iejoin/test_ieantijoin.test"
            "test/sql/join/iejoin/test_iejoin.test"
            "test/sql/join/iejoin/test_iejoin_east_west.test"
            "test/sql/join/iejoin/test_iejoin_events.test"
            "test/sql/join/iejoin/test_iejoin_null_keys.test"
            "test/sql/join/iejoin/test_iejoin_overlaps.test"
            "test/sql/join/iejoin/test_iejoin_predicate.test"
            "test/sql/join/iejoin/test_iejoin_sort_tasks.test_slow"
            "test/sql/join/iejoin/test_iesemijoin.test"
            # asof tests that loop debug_asof_iejoin=True, forcing the IEJoin path
            "test/sql/join/asof/test_asof_join_inequalities.test"
            "test/sql/join/asof/test_asof_join_missing.test_slow"
            # 10240-row inequality join routing to IEJoin via plan_comparison_join.cpp
            "test/sql/join/test_complex_range_join.test"
            # fails on aarch64-darwin, read-ahead memory limit test
            "test/sql/copy/parquet/read_ahead/readahead_memory_limit.test"
          ]
        );
        LD_LIBRARY_PATH = lib.optionalString stdenv.hostPlatform.isDarwin "DY" + "LD_LIBRARY_PATH";
      in
      ''
        runHook preInstallCheck
        (($(ulimit -n) < 1024)) && ulimit -n 1024

        status=0
        HOME="$(mktemp -d)" ${LD_LIBRARY_PATH}="$lib/lib" ./test/unittest ${toString excludes} 2>&1 \
          | tee unittest.log || status=$?
        if [ "$status" -ne 0 ]; then
          # failure details scroll out of the log tail nix prints, so list the failing tests last
          echo "failing tests:"
          grep -E '^[0-9]+\. ' unittest.log || true
          exit "$status"
        fi

        runHook postInstallCheck
      '';

    passthru = {
      inherit extensions;

      link =
        let
          libDir = "${finalAttrs.finalPackage.lib}/lib";
          # always loaded by extension/extension_config.cmake
          builtinExtensions = map mkExtension (
            [
              "core_functions"
              "parquet"
            ]
            ++ lib.optionals withIcu [ "icu" ]
            ++ lib.optionals withJson [ "json" ]
          );
          staticExtensions = builtinExtensions ++ inTreeExtensions ++ linkedExtensions;
          # add_third_party in CMakeLists.txt, which only builds jemalloc on 64-bit linux
          thirdPartyLibraries = [
            "fastpforlib"
            "fmt"
            "fsst"
            "hyperloglog"
            "mbedtls"
            "miniz"
            "re2"
            "skiplistlib"
            "utf8proc"
            "yyjson"
            "zstd"
          ]
          ++ lib.optionals (
            stdenv.hostPlatform.isLinux && stdenv.hostPlatform.is64bit && !stdenv.hostPlatform.isAndroid
          ) [ "jemalloc" ];
          archiveNames = [
            "libduckdb_static.a"
            staticExtensionLoaderArchive
          ]
          ++ map (extension: "lib${extension.name}_extension.a") staticExtensions
          ++ map (library: "libduckdb_${library}.a") (capabilities ++ thirdPartyLibraries);
          archives = map (archive: "${libDir}/${archive}") archiveNames;
          # keeps the autoregistration, which nothing references
          undefinedSymbols = [
            "${lib.optionalString stdenv.hostPlatform.isDarwin "_"}${staticExtensionLoaderSymbol}"
          ];
          systemLibraries = [
            (if stdenv.hostPlatform.isDarwin then "c++" else "stdc++")
            "m"
          ];
          # ld64 searches archives repeatedly by itself and has no --start-group
          groupArchives = !stdenv.hostPlatform.isDarwin;
          driverFlags = [ "-pthread" ];
          # gcc and clang read the linker flags of extension system libraries from this file
          systemLibraryFlagsFile =
            if pkgConfigModules == [ ] then null else "${finalAttrs.finalPackage.dev}/${systemLibrariesFile}";
        in
        {
          includeDir = "${finalAttrs.finalPackage.dev}/include";
          inherit libDir;

          shared = {
            library = "duckdb";
            flags = [
              "-L${libDir}"
              "-lduckdb"
            ];
          };

          static = {
            inherit
              archives
              undefinedSymbols
              systemLibraries
              driverFlags
              pkgConfigModules
              systemLibraryFlagsFile
              groupArchives
              ;
            extensions = map (extension: extension.name) staticExtensions;
            registeredExtensions = capabilities ++ finalAttrs.passthru.link.static.extensions;
            flags =
              map (symbol: "-Wl,-u,${symbol}") undefinedSymbols
              ++ lib.optional groupArchives "-Wl,--start-group"
              ++ archives
              ++ lib.optional groupArchives "-Wl,--end-group"
              ++ lib.optional (systemLibraryFlagsFile != null) "@${systemLibraryFlagsFile}"
              ++ map (library: "-l${library}") systemLibraries
              ++ driverFlags;
          };
        };

      # also pins the out-of-tree extensions to the commits this release builds
      updateScript = [
        "bash"
        "packages/duckdb/update.sh"
      ];
    };

    meta = {
      changelog = "https://github.com/duckdb/duckdb/releases/tag/v${finalAttrs.version}";
      description = "Embeddable SQL OLAP Database Management System";
      homepage = "https://duckdb.org/";
      license = lib.licenses.mit;
      mainProgram = "duckdb";
      maintainers = with lib.maintainers; [ spotdemo4 ];
      platforms = lib.platforms.all;
    };
  })
)
