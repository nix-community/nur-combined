{
  fetchFromGitHub,
  lib,
  postgresql,
  buildPgrxExtension,
  callPackage,
  clang,
  icu,
  fetchurl,
}:

buildPgrxExtension (finalAttrs: {
  inherit postgresql;
  cargo-pgrx = callPackage ./cargo-pgrx.nix { };

  pname = "pg_search";
  version = "0.18.11";

  src = fetchFromGitHub {
    owner = "paradedb";
    repo = "paradedb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pU2K74QHdrQP1vKo2NL8qt3luYlEVn2OGZ4ZEEqAqzI=";
  };

  doCheck = false;

  cargoPgrxFlags = [
    "--package"
    "pg_search"
  ];

  buildInputs = [
    clang
    icu
  ];

  passthru.lindera-srcs = {
    cc-cedict-mecab = fetchurl {
      passthru.vendorDir = "lindera-cc-cedict-*";
      url = "https://lindera.dev/CC-CEDICT-MeCab-0.1.0-20200409.tar.gz";
      hash = "sha256-7Tz54+yKgGR/DseD3Ana1DuMytLplPXqtv8TpB0JFsg=";
    };
    mecab-ipadic = fetchurl {
      passthru.vendorDir = "lindera-ipadic-0.*";
      url = "https://Lindera.dev/mecab-ipadic-2.7.0-20070801.tar.gz";
      hash = "sha256-CZ5G6A1V58DWkGeDr/cTdI4a6Q9Gxe+W7BU7vwm/VVA=";
    };
    mecab-ko-dic = fetchurl {
      passthru.vendorDir = "lindera-ko-dic-*";
      url = "https://Lindera.dev/mecab-ko-dic-2.1.1-20180720.tar.gz";
      hash = "sha256-cCztIcYWfp2a68Z0q17lSvWNREOXXylA030FZ8AgWRo=";
    };
    mecab-ipadic-neologd = fetchurl {
      passthru.vendorDir = "lindera-ipadic-neologd-*";
      url = "https://lindera.dev/mecab-ipadic-neologd-0.0.7-20200820.tar.gz";
      hash = "sha256-1VwCwgSTKFixeQUFVCdqMzZKne/+FTgM56xT7etqjqI=";
    };
    unidic-mecab = fetchurl {
      passthru.vendorDir = "lindera-unidic-*";
      url = "https://Lindera.dev/unidic-mecab-2.1.2.tar.gz";
      hash = "sha256-JKx1/k5E2XO1XmWEfDX6Suwtt6QaB7ScoSUUbbn8EYk=";
    };
  };

  postPatch = ''
    # patch build-time dependency downloads
    (
      # add support for file:// urls
      patch -d $cargoDepsCopy/lindera-dictionary-*/ -p1 < ${./lindera-dictionary-support-file-paths.patch}

      # patch urls
      ${lib.pipe finalAttrs.passthru.lindera-srcs [
        (lib.mapAttrsToList (
          key: src: ''
            # compgen is only in bashInteractive
            declare -a expanded_glob=($cargoDepsCopy/${src.vendorDir}/build.rs)
            if [[ "''${#expanded_glob[@]}" -eq 0 ]]; then
              echo >&2 "ERROR: '$cargoDepsCopy/${src.vendorDir}/build.rs' not found! (pagefind.passthru.lindera-srcs.${key})"
              false
            elif [[ "''${#expanded_glob[@]}" -gt 1 ]]; then
              echo >&2 "ERROR: '$cargoDepsCopy/${src.vendorDir}/build.rs' matches more than one file! (pagefind.passthru.lindera-srcs.${key})"
              printf >&2 "match: %s\n" "''${expanded_glob[@]}"
              false
            fi
            echo "patching $cargoDepsCopy/${src.vendorDir}/build.rs..."
            substituteInPlace $cargoDepsCopy/${src.vendorDir}/build.rs --replace-fail "${src.url}" "file://${src}"
            unset expanded_glob
          ''
        ))
        lib.concatLines
      ]}
    )
  '';

  cargoHash = "sha256-M6Kyk6vdiq9W6GQ21JwGzd/hmWnLmXWnF7o+Rhg2PnU=";

  preferLocalBuild = true;

  meta = {
    description = "The transactional Elasticsearch alternative built on Postgres";
    homepage = "https://github.com/paradedb/paradedb/";
    changelog = "https://github.com/paradedb/paradedb/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    platforms = postgresql.meta.platforms;
    maintainers = [ ];
  };
})
