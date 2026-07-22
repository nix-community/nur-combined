{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  cmake,
  ninja,
  openssl,
  openjdk11,
  nix-update-script,
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
    ++ lib.optionals withIcu [ "icu" ]
    ++ lib.optionals withJson [ "json" ]
    ++ lib.optionals withTpcds [ "tpcds" ]
    ++ lib.optionals withTpch [ "tpch" ]
  );

  extensions = callPackage ./extensions { };
  externalExtensionDrvs =
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
    ++ lib.optionals withVss [ extensions.vss ];

  externalExtensions = map (
    extension:
    extension.passthru.duckdbExtension
    // {
      src = extension;
    }
  ) externalExtensionDrvs;

  enabledExtensions = inTreeExtensions ++ externalExtensions;

  externalExtensionBuildInputs = lib.concatMap (
    extension: extension.duckdbBuildInputs
  ) externalExtensions;
  externalExtensionPostPatchCommands = lib.concatMapStringsSep "\n" (
    extension: extension.duckdbPostPatch
  ) externalExtensions;

  formatExtensionLoad =
    extension:
    if extension.loadOptions == [ ] then
      "duckdb_extension_load(${extension.name})"
    else
      lib.concatStringsSep "\n" (
        [ "duckdb_extension_load(${extension.name}" ]
        ++ map (option: "    ${option}") extension.loadOptions
        ++ [ ")" ]
      );

  extensionLoadConfig = lib.concatMapStringsSep "\n" (
    extension: formatExtensionLoad extension
  ) enabledExtensions;

  externalExtensionCopyCommands = lib.concatMapStringsSep "\n" (
    extension:
    let
      destination = "extension_external/${extension.name}";
    in
    ''
      cp -R ${lib.escapeShellArg (toString extension.src)} ${lib.escapeShellArg destination}
      chmod -R u+w ${lib.escapeShellArg destination}
    ''
  ) externalExtensions;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "duckdb";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "duckdb";
    repo = "duckdb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vFXrMcWF5KDYYRjWZb6iJdhGnCAb6SMlSgzlcr+FQ8Y=";
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
  ];
  buildInputs = [
    openssl
  ]
  ++ externalExtensionBuildInputs
  ++ lib.optionals withJdbc [ openjdk11 ]
  ++ lib.optionals withOdbc [ unixodbc ];

  patches = lib.optionals stdenv.hostPlatform.isStatic [
    ./static-no-loadable-extensions.patch
  ];

  postPatch = lib.optionalString (enabledExtensions != [ ]) ''
    ${lib.optionalString (externalExtensions != [ ]) ''
      mkdir -p extension_external
      ${externalExtensionCopyCommands}
    ''}

    ${externalExtensionPostPatchCommands}

    cat >> extension/extension_config.cmake <<'EOF'

    ${extensionLoadConfig}
    EOF
  '';

  cmakeFlags = [
    (lib.cmakeBool "BUILD_ODBC_DRIVER" withOdbc)
    (lib.cmakeBool "JDBC_DRIVER" withJdbc)
    (lib.cmakeBool "NIX_STATIC_BUILD" stdenv.hostPlatform.isStatic)
    (lib.cmakeFeature "OVERRIDE_GIT_DESCRIBE" "v${finalAttrs.version}")
    # development settings
    (lib.cmakeBool "BUILD_UNITTESTS" finalAttrs.doInstallCheck)
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
          # wants http connection
          "test/sql/copy/csv/recursive_query_csv.test"
          "test/sql/copy/csv/test_mixed_lines.test"
          "test/parquet/parquet_long_string_stats.test"
          "test/sql/attach/attach_remote.test"
          "test/sql/attach/remote_file_concurrently.test"
          "test/sql/copy/csv/test_sniff_httpfs.test"
          "test/sql/httpfs/internal_issue_2490.test"
          # fails with incorrect result
          # Upstream issue https://github.com/duckdb/duckdb/issues/14294
          "test/sql/copy/file_size_bytes.test"
          # https://github.com/duckdb/duckdb/issues/17757#issuecomment-3032080432
          "test/issues/general/test_17757.test"
        ]
        ++ lib.optionals stdenv.hostPlatform.isStatic [
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
        ]
      );
      LD_LIBRARY_PATH = lib.optionalString stdenv.hostPlatform.isDarwin "DY" + "LD_LIBRARY_PATH";
    in
    ''
      runHook preInstallCheck
      (($(ulimit -n) < 1024)) && ulimit -n 1024

      HOME="$(mktemp -d)" ${LD_LIBRARY_PATH}="$lib/lib" ./test/unittest ${toString excludes}

      runHook postInstallCheck
    '';

  passthru = {
    inherit extensions;

    updateScript = nix-update-script {
      extraArgs = [
        "--commit"
        finalAttrs.pname
      ];
    };
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
