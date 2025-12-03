# nixpkgs/pkgs/development/python-modules/selenium/default.nix

{ lib
, fetchFromGitHub
, fetchPypi
, fetchurl
, buildPythonPackage
, setuptools
, wheel
, certifi
, geckodriver
, pytestCheckHook
, pythonOlder
, trio
, trio-websocket
, urllib3
, typing-extensions
, websocket-client
, setuptools-rust
, rustc
, cargo
, rustPlatform
, pytest-trio
, nixosTests
, stdenv
, python
}:

buildPythonPackage rec {
  pname = "selenium";
  # nixpkgs version: 4.29.0
  version = "4.34.0";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "SeleniumHQ";
    repo = "selenium";
    # check if there is a newer tag with or without -python suffix
    rev = "refs/tags/selenium-${version}";
    hash = "sha256-7ZKLFaXmDcQAZ1XOvWWl3LhXGiI2K9GfTbtNJB26nfw=";
  };

  # also add selenium.webdriver.common.devtools.* packages
  # fix: ModuleNotFoundError: No module named 'selenium.webdriver.common.devtools'

  src-pypi = fetchPypi {
    inherit pname version;
    hash = "sha256-i36wWg7SL5uyGH/SVsKGMIJK0B2Dl7Tmi8CvfavybIA=";
  };

  # based on https://github.com/SeleniumHQ/selenium/blob/trunk/common/selenium_manager.bzl
  # see also https://github.com/SeleniumHQ/selenium/blob/trunk/scripts/selenium_manager.py
  # FIXME build selenium-manager from source

  /*
  src-selenium-manager-bin = let version = "9d09338"; in fetchurl {
    url = "https://github.com/SeleniumHQ/selenium_manager_artifacts/releases/download/selenium-manager-${version}/selenium-manager-linux";
    hash = "sha256-9hWuLupxSlTjIviUXHq7GeA+D11lG0ZL1c2ens+efJA=";
  };
  */

  # relax versions
  # fix: typing-extensions~=4.9 not satisfied by version 4.8.0
  # https://github.com/SeleniumHQ/selenium/blob/trunk/py/setup.py

  # also add selenium.webdriver.common.devtools.* packages
  # fix: ModuleNotFoundError: No module named 'selenium.webdriver.common.devtools'
  # https://github.com/milahu/nixpkgs/issues/20

  postUnpack = ''
    pushd $sourceRoot
    echo unpacking selenium/webdriver/common/devtools from ${src-pypi}
    tar --strip-components=1 --wildcards -x -f ${src-pypi} 'selenium-*/selenium/webdriver/common/devtools'
    popd
  '';

  # https://ryantm.github.io/nixpkgs/languages-frameworks/rust/#examples
  cargoDeps = rustPlatform.fetchCargoVendor {
    sourceRoot = "source/rust";
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-UDsS2N3KWUcq6x5ajFQ1vVFsp/aGHaXSbCMzb+aI/bQ=";
  };

  sourceRoot = "source/py";

  /*
    # cd py
    # fix typo
    # FIXME sed: can't read setup.py: No such file or directory
    if false; then
    sed -i 's/typing_extension~=/typing_extensions~=/' setup.py
    sed -i 's/[~>]=.*"/"/' setup.py
    substituteInPlace setup.py \
      --replace \
        "    'packages': [" \
        "    'packages': find_namespace_packages(where='.'), '_packages': [" \
      --replace \
        "from setuptools import setup" \
        "from setuptools import setup, find_namespace_packages"
    fi
    # fix: ValueError: ZIP does not support timestamps before 1980
    # https://github.com/SeleniumHQ/selenium/issues/14143
    substituteInPlace selenium/webdriver/firefox/firefox_profile.py \
      --replace-warn \
        'with zipfile.ZipFile(fp, "w", zipfile.ZIP_DEFLATED) as zipped:' \
        'with zipfile.ZipFile(fp, "w", zipfile.ZIP_DEFLATED, strict_timestamps=False) as zipped:'

    # quickfix: error: can't find manifest for Rust extension `selenium.webdriver.common.selenium-manager` at path `Cargo.toml`
    cp -r ../rust/* .
    # cd .. # undo: cd py
  */
  postPatch = ''
    # unpin dependencies
    sed -i -E 's/^(    ".*)[~>=]=.*(",)/\1\2/' pyproject.toml

    # quickfix: ERROR: Missing Cargo.lock from src. Expected to find it at: /build/source/py/Cargo.lock
    cp -r ../rust/* .
  '';

  # FIXME
  /*
    test/selenium/webdriver/common/bidi_webextension_tests.py:24: in <module>
        from python.runfiles import Runfiles
    E   ModuleNotFoundError: No module named 'python'
  */
  doCheck = false;

  postInstall = ''
    DST_PREFIX=$out/lib/${python.libPrefix}/site-packages/selenium/webdriver/
    DST_REMOTE=$DST_PREFIX/remote/
    DST_FF=$DST_PREFIX/firefox
    cp ../rb/lib/selenium/webdriver/atoms/getAttribute.js $DST_REMOTE
    cp ../rb/lib/selenium/webdriver/atoms/isDisplayed.js $DST_REMOTE
    cp ../rb/lib/selenium/webdriver/atoms/findElements.js $DST_REMOTE
    cp ../javascript/cdp-support/mutation-listener.js $DST_REMOTE
    cp ../third_party/js/selenium/webdriver.json $DST_FF/webdriver_prefs.json
  '' + lib.optionalString stdenv.isDarwin ''
    mkdir -p $DST_PREFIX/common/macos
    cp ../common/manager/macos/selenium-manager $DST_PREFIX/common/macos
  '' + lib.optionalString stdenv.isLinux ''
    mkdir -p $DST_PREFIX/common/linux/
  '';
  /*
    cp -v ${src-selenium-manager-bin} $DST_PREFIX/common/linux/selenium-manager
    chmod +x $DST_PREFIX/common/linux/selenium-manager
  */

  nativeBuildInputs = [
    setuptools
    setuptools-rust
    wheel
    rustc
    cargo
    rustPlatform.cargoSetupHook
  ];

  propagatedBuildInputs = [
    certifi
    trio
    trio-websocket
    urllib3
    typing-extensions
    websocket-client
  ] ++ urllib3.optional-dependencies.socks;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-trio
  ];

  passthru.tests = {
    testing-vaultwarden = nixosTests.vaultwarden;
  };

  meta = with lib; {
    description = "Bindings for Selenium WebDriver";
    homepage = "https://selenium.dev/";
    license = licenses.asl20;
    maintainers = with maintainers; [ jraygauthier ];
  };
}
