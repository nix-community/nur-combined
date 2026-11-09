# based on https://github.com/NixOS/nixpkgs/pull/451547

# pkgs/development/python-modules/camoufox/default.nix

# FIXME LeakWarning: Canvas and WebGL readback return random data,
# as privacy.resistFingerprinting does in LibreWolf, Tor Browser and Mullvad Browser.
# Stock Firefox does not do this, so the browser reads as a privacy-hardened Firefox.
# It is on because the identity claims another OS or GPU than this machine's,
# whose canvas would show the real one. Pass `canvas_noise=False` to keep stock canvas behaviour.

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
    # https://github.com/daijro/camoufox/pull/998
    rev = "226de28bdc39e2f81b00dd366aa8ab62c20f43fa";
    hash = "sha256-PXfIRg66kCZhF8DIXZamIbZqrt0RCKhfy6aPapMOZ2Q=";
  };

  sourceRoot = "source/python";
  # sourceRoot = "camoufox/python";

  camoufoxFontconfigDir = stdenv.mkDerivation {
    # TODO? pname + version
    name = "camoufox-fontconfig-dir";
    src = pkgs-camoufox.camoufoxSource;
    buildPhase = ''
      cp -r browser/bundle/fontconfig $out
      for conf in "$out/"*"/fonts.conf"; do
        echo "patching fonts dir in $conf"
        substituteInPlace "$conf" \
          --replace-fail \
            '<dir prefix="cwd">fonts</dir>' \
            '<dir prefix="cwd">${pkgs-camoufox.camoufoxFontBundle}</dir>'
      done
    '';
  };

  postPatch = ''
    camoufoxPropertiesJson=${pkgs-camoufox.camoufoxSource}/browser/settings/properties.json
    if ! [ -e $camoufoxPropertiesJson ]; then
      echo "error: missing file: $camoufoxPropertiesJson"
      exit 1
    fi

    # camoufoxFontconfigDir=${pkgs-camoufox.camoufoxSource}/browser/bundle/fontconfig
    camoufoxFontconfigDir=${camoufoxFontconfigDir}
    if ! [ -d $camoufoxFontconfigDir ]; then
      echo "error: missing directory: $camoufoxFontconfigDir"
      exit 1
    fi

    # set default values
    substituteInPlace src/camoufox/pkgman.py \
      --replace-fail \
        'configured_path = os.environ.get("CAMOUFOX_BROWSER_PATH")' \
        'configured_path = os.environ.get("CAMOUFOX_BROWSER_PATH") or "${pkgs-camoufox}/lib/camoufox"' \
      --replace-fail \
        'env_version = os.environ.get("CAMOUFOX_BROWSER_VERSION")' \
        'env_version = os.environ.get("CAMOUFOX_BROWSER_VERSION") or "${pkgs-camoufox.firefoxVersion}"' \
      --replace-fail \
        'env_build = os.environ.get("CAMOUFOX_BROWSER_BUILD")' \
        'env_build = os.environ.get("CAMOUFOX_BROWSER_BUILD") or "${pkgs-camoufox.camoufoxVersion}"'

    substituteInPlace src/camoufox/addons.py \
      --replace-fail \
        'default_path_by_addon_name = {}' \
        'default_path_by_addon_name = {"UBO": "${firefox-addons.ublock-origin}"}'

    substituteInPlace src/camoufox/utils.py \
      --replace-fail \
        'os.environ.get("CAMOUFOX_PROPERTIES_JSON")' \
        'os.environ.get("CAMOUFOX_PROPERTIES_JSON") or "'$camoufoxPropertiesJson'"' \
      --replace-fail \
        'os.environ.get("CAMOUFOX_FONTCONFIG_DIR")' \
        'os.environ.get("CAMOUFOX_FONTCONFIG_DIR") or "'$camoufoxFontconfigDir'"' \

    # dont download an fpgen model from GitHub
    # FIXME fpgen should use a model from the Nix store
    # Fetching model files from GitHub...
    # OSError: [Errno 30] Read-only file system: '/nix/store/xzpr45p0hsjsgaamwz4xh1xxvw7yaiih-python3-3.14.7-env/lib/python3.14/site-packages/fpgen/data'
    substituteInPlace src/camoufox/fpgen_model.py \
      --replace-fail \
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
