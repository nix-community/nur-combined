# based on https://github.com/NixOS/nixpkgs/pull/451547

# pkgs/development/python-modules/camoufox/default.nix

{
  lib,
  buildPythonPackage,
  stdenv,
  # fetchPypi,
  fetchFromGitHub,
  fetchurl,
  unzip,
  # Build-time dependencies
  poetry-core,
  # Runtime dependencies
  browserforge,
  requests,
  language-tags,
  lxml,
  numpy,
  platformdirs,
  playwright,
  pysocks,
  pyyaml,
  screeninfo,
  tqdm,
  ua-parser,
  fpgen,
  inquirer,
  rich-click,

  # TODO
  pkgs-camoufox,
}:

let
  firefox-addons = {
    ublock-origin = stdenv.mkDerivation rec {
      pname = "ublock-origin-firefox";
      version = "1.75.5rc3";
      # FIXME build from source
      src = fetchurl {
        url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.firefox.signed.xpi";
        hash = "sha256-XQlshmRPNxmwzqwxwmXKM6c52xuCQAz62vQP4tf+//I=";
      };
      nativeBuildInputs = [
        unzip
      ];
      buildCommand = ''
        mkdir $out
        cd $out
        echo "unpacking $src"
        unzip $src
      '';
    };
  };
in

buildPythonPackage rec {
  pname = "camoufox";

  # version = "0.4.11";
  # TODO? re-use pkgs-camoufox.version
  version = "158.0.1-beta.41";

  format = "pyproject";

  /*
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-CiydJKxQcMEE58KxJcCjk39w76QWCE74iv6Uwypy7r4=";
  };
  */

  src =
  # if true then /home/user/src/milahu/nur-packages/camoufox else
  fetchFromGitHub {
    # owner = "daijro";
    owner = "milahu";
    repo = "camoufox";
    /*
    tag = "v${version}";
    hash = "sha256-w5c8KvHSPMCyHG+V9m169Q5RCt/enDsJof+VnXpqmoU=";
    */
    # add support for offline packaging
    rev = "b5eed9c1c34b98e471c7be813d601cfc9cbf1070";
    hash = "sha256-9B65NbTVqGHDk23radSeqLA/szXCjh3aLDiBBK/1RcM=";
  };

  sourceRoot = "source/python";
  # sourceRoot = "camoufox/python";

  postPatch = ''
    # set default values
    substituteInPlace src/camoufox/pkgman.py \
      --replace \
        'configured_path = os.environ.get("CAMOUFOX_BROWSER_PATH")' \
        'configured_path = os.environ.get("CAMOUFOX_BROWSER_PATH") or "${pkgs-camoufox}/lib/camoufox"' \
      --replace \
        'env_version = os.environ.get("CAMOUFOX_BROWSER_VERSION")' \
        'env_version = os.environ.get("CAMOUFOX_BROWSER_VERSION") or "${pkgs-camoufox.firefoxVersion}"' \
      --replace \
        'env_build = os.environ.get("CAMOUFOX_BROWSER_BUILD")' \
        'env_build = os.environ.get("CAMOUFOX_BROWSER_BUILD") or "${pkgs-camoufox.camoufoxVersion}"'

    substituteInPlace src/camoufox/addons.py \
      --replace \
        'default_path_by_addon_name = {}' \
        'default_path_by_addon_name = {"UBO": "${firefox-addons.ublock-origin}"}'

    # dont download an fpgen model from GitHub
    # FIXME fpgen should use a model from the Nix store
    # Fetching model files from GitHub...
    # OSError: [Errno 30] Read-only file system: '/nix/store/xzpr45p0hsjsgaamwz4xh1xxvw7yaiih-python3-3.14.7-env/lib/python3.14/site-packages/fpgen/data'
    substituteInPlace src/camoufox/fpgen_model.py \
      --replace \
        'if os.getenv(CUSTOM_MODEL_ENV):' \
        'if True: # if os.getenv(CUSTOM_MODEL_ENV):'
  '';

  nativeBuildInputs = [
    poetry-core
  ];

  dependencies = [
    browserforge
    requests
    language-tags
    lxml
    numpy
    platformdirs
    playwright
    pysocks
    pyyaml
    screeninfo
    tqdm
    ua-parser
    fpgen
    inquirer
    rich-click
  ];

  # The import check fails because of network access.
  # We disable it, which is the standard procedure in this case.
  doPythonImportsCheck = false;

  # We no longer need this line, as we are disabling the check entirely.
  # pythonImportsCheck = [ "camoufox" ];

  doCheck = false;

  meta = with lib; {
    description = "Lightweight wrapper around the Playwright API to help launch Camoufox.";
    homepage = "https://github.com/daijro/camoufox";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
