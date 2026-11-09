{
  lib,
  buildPythonPackage,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  unzip,
  pkgs-zstd,
  poetry-core,
  click,
  httpx,
  indexed-zstd,
  numpy,
  orjson,
  zstandard,
  nix-update-script,
}:

buildPythonPackage (finalAttrs: {
  pname = "fpgen";
  # https://pypi.org/project/fpgen/#history
  version = "1.3.0"; # 2025-03-22
  # latest model-release.zip from https://github.com/scrapfly/fingerprint-generator/releases
  dataVersion = "2/2026";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "scrapfly";
    repo = "fingerprint-generator";
    # tag = "model-${finalAttrs.dataVersion}";
    # https://github.com/scrapfly/fingerprint-generator/pull/8
    # use DATA_DIR from env
    rev = "026e0dbc0f7d7daad90c16bb178da7c99050e2ad";
    hash = "sha256-otOZ3ftDBYLsqS9Obi2QcHEQjtKX4O4nZOUq4cAeP8U=";
  };

  # NOTE wording: "data" is more generic than "model"
  data = stdenv.mkDerivation {
    pname = "fpgen-data";
    # example: "2/2026" -> "2026-02"
    version = (
      let
        monthYear = lib.flatten (builtins.split "/" finalAttrs.dataVersion);
        month = lib.fixedWidthString 2 "0" (builtins.elemAt monthYear 0);
        year = builtins.elemAt monthYear 1;
      in
      "${year}-${month}"
    );
    src = (
      let
        dataVersionUrlencoded = builtins.replaceStrings ["/"] ["%2F"] finalAttrs.dataVersion;
      in
      fetchurl {
        url = "https://github.com/scrapfly/fingerprint-generator/releases/download/model-${dataVersionUrlencoded}/model-release.zip";
        hash = "sha256-ZTC4MizapOwEKSHI2aA2mg5uAmm6Y2wBpyA+Si8QmTY=";
      }
    );
    # fix: unpacker appears to have produced no directories
    sourceRoot = ".";
    buildPhase = ''
      mkdir $out
      # based on pkgman.py: def decompress_model
      echo "extracting zst files"
      for zst in *.zst; do
        o=$out/''${zst%.*}
        echo "extracting $zst to $o"
        zstd -d "$zst" -o "$o"
      done
    '';
    nativeBuildInputs = [
      unzip
      pkgs-zstd
    ];
  };

  postPatch = ''
    # set default values
    substituteInPlace fpgen/pkgman.py \
      --replace \
        "os.getenv('FPGEN_DATA_DIR')" \
        "os.getenv('FPGEN_DATA_DIR') or '${finalAttrs.data}'" \
      --replace \
        "os.getenv('FPGEN_DATA_IS_RECENT')" \
        "os.getenv('FPGEN_DATA_IS_RECENT', None if os.getenv('FPGEN_DATA_DIR') else '1')"
  '';

  build-system = [
    poetry-core
  ];

  dependencies = [
    click
    httpx
    indexed-zstd
    numpy
    orjson
    zstandard
  ];

  # import fails: "Fetching model files from GitHub..."
  # pythonImportsCheck = [ "fpgen" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Browser fingerprint data generator";
    homepage = "https://github.com/scrapfly/fingerprint-generator";
    # changelog = "https://github.com/scrapfly/fingerprint-generator/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
})
