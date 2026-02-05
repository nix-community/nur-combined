{
  lib,
  buildPgrxExtension,
  postgresql,
  cargo-pgrx_0_16_1,
  fetchFromGitHub,
  clang,
  icu,
  fetchurl,
}:

buildPgrxExtension (finalAttrs: {
  inherit postgresql;
  cargo-pgrx = cargo-pgrx_0_16_1;

  pname = "pg_search";
  version = "0.21.6";

  src = fetchFromGitHub {
    owner = "paradedb";
    repo = "paradedb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/VUyPeIvizuCVEE33GkVv/dcIIYwtwvD584XuyBTsCo=";
  };

  cargoHash = "sha256-ox5g+VQ31M6TZsyBMQAZv25ymkJPTcgPHoRtQxe+Bd8=";

  # https://github.com/NixOS/nixpkgs/blob/1e5d278f3159de05fdc39bb557be3ba4e1a201c4/pkgs/by-name/pa/pagefind/package.nix
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
              echo >&2 "ERROR: '$cargoDepsCopy/${src.vendorDir}/build.rs' not found! (pg_search.passthru.lindera-srcs.${key})"
              false
            elif [[ "''${#expanded_glob[@]}" -gt 1 ]]; then
              echo >&2 "ERROR: '$cargoDepsCopy/${src.vendorDir}/build.rs' matches more than one file! (pg_search.passthru.lindera-srcs.${key})"
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

  cargoPgrxFlags = [
    "--package"
    "pg_search"
  ];

  buildInputs = [
    clang
    icu
  ];

  doCheck = false;

  # the lindera-unidic v1.4.1 crate uses [1] an outdated unidic-mecab fork [2] and builds it in pure rust
  # [1] https://github.com/lindera/lindera/blob/v1.4.1/lindera-unidic/build.rs#L15-L22
  # [2] https://github.com/lindera/unidic-mecab
  # To find these urls:
  #   rg -A5 download_urls $(nix-build . -A pg_search.cargoDeps --no-out-link)/lindera-*/build.rs
  passthru.lindera-srcs = {
    unidic-mecab = fetchurl {
      passthru.vendorDir = "lindera-unidic-*";
      url = "https://Lindera.dev/unidic-mecab-2.1.2.tar.gz";
      hash = "sha256-JKx1/k5E2XO1XmWEfDX6Suwtt6QaB7ScoSUUbbn8EYk=";
    };
    ipadic-neologd = fetchurl {
      passthru.vendorDir = "lindera-ipadic-neologd-*";
      url = "https://lindera.dev/mecab-ipadic-neologd-0.0.7-20200820.tar.gz";
      hash = "sha256-1VwCwgSTKFixeQUFVCdqMzZKne/+FTgM56xT7etqjqI=";
    };
    mecab-ko-dic = fetchurl {
      passthru.vendorDir = "lindera-ko-dic-*";
      url = "https://Lindera.dev/mecab-ko-dic-2.1.1-20180720.tar.gz";
      hash = "sha256-cCztIcYWfp2a68Z0q17lSvWNREOXXylA030FZ8AgWRo=";
    };
    ipadic = fetchurl {
      passthru.vendorDir = "lindera-ipadic-1.*";
      url = "https://Lindera.dev/mecab-ipadic-2.7.0-20250920.tar.gz";
      hash = "sha256-p7qfZF/+cJTlauHEqB0QDfj7seKLvheSYi6XKOFi2z0=";
    };
    cc-cedict = fetchurl {
      passthru.vendorDir = "lindera-cc-cedict-*";
      url = "https://lindera.dev/CC-CEDICT-MeCab-0.1.0-20200409.tar.gz";
      hash = "sha256-7Tz54+yKgGR/DseD3Ana1DuMytLplPXqtv8TpB0JFsg=";
    };
  };

  meta = with lib; {
    description = "Simple, Elastic-quality search for Postgres";
    homepage = "https://github.com/paradedb/paradedb";
    changelog = "https://docs.paradedb.com/changelog/${finalAttrs.version}";
    license = licenses.agpl3Only;
    inherit (postgresql.meta) platforms;
    maintainers = with maintainers; [ xyenon ];
  };
})
