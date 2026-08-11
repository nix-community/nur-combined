/*

  FIXME this is not working
  test-botasaurus.py will print "heading None"
  but heading should be a <h1> element

  nix-shell -E '
    let
      pkgs = import <nixpkgs> {};
      nurRepo = import ./. {};
    in
    pkgs.mkShell {
      buildInputs = [
        nurRepo.python3.pkgs.botasaurus
      ];
    }
  '

  echo $PYTHONPATH | tr : $'\n' | grep botasaurus

  python pkgs/python3/pkgs/botasaurus/test-botasaurus.py

*/

{ lib
, python3
, fetchFromGitHub
, chromium
, chromedriver
, npmlock2nix
}:

let

  node_modules = npmlock2nix.node_modules {
    # FIXME src should be optional
    src = ./.;
    #symlinkNodeModules = true;
    packageJson = ./package.json;
    packageLockJson = ./package-lock.json;
  };

in

assert chromium.version == chromedriver.version;

python3.pkgs.buildPythonApplication rec {
  pname = "botasaurus";
  # https://pypi.org/project/botasaurus/
  version = "3.2.3"; # 2024-01-12
  pyproject = true;

  src = fetchFromGitHub {
    owner = "omkarcloud";
    repo = "botasaurus";
    rev = "34ad082fb7f2455b330f05207f0535c91fa57475";
    hash = "sha256-Q2hAO8vye08W71SXW0hPqNmm99ahyhkw3N8JETod9wI=";
  };

  # jsPyBridgeCacheEnv must be set before "from javascript import require"

  postPatch = ''
    while read filePath; do
      substituteInPlace "$filePath" \
        --replace \
          "from javascript import require" \
          $'import os\nos.environ["'$jsPyBridgeCacheEnv'"] = "'$out$jsPyBridgeCachePath$'"\nfrom javascript import require'
    done < <(
      grep -r -l "from javascript import require" botasaurus/
    )

    substituteInPlace botasaurus/get_chrome_version.py \
      --replace \
        $'def get_linux_executable_path():' \
        $'def get_linux_executable_path():\n    return "${chromium}/bin/${chromium.meta.mainProgram}"' \
      --replace \
        $'def get_chrome_version():' \
        $'def get_chrome_version():\n    return "${chromium.version}"' \
      --replace \
        $'def get_driver_path():' \
        $'def get_driver_path():\n    return "${chromedriver}/bin/chromedriver"' \
      --replace \
        $'def get_matched_chromedriver_version(chrome_version, no_ssl=False):' \
        $'def get_matched_chromedriver_version(chrome_version, no_ssl=False):\n    return "${chromedriver.version}"' \
  '';

  # custom env added in pkgs/python3/pkgs/javascript/javascript.nix
  # https://github.com/extremeheat/JSPyBridge/issues/117
  # site-packages should be treated as read-only
  jsPyBridgeCacheEnv = "JS_PY_BRIDGE_CACHE";

  # TODO better place than /cache? /lib? /share? /opt?
  jsPyBridgeCachePath = "/cache/js-py-bridge";

  postBuild = ''
    mkdir -p $out$jsPyBridgeCachePath
    ln -s -v ${node_modules}/node_modules $out$jsPyBridgeCachePath/node_modules
    cp -v ${./package.json} $out$jsPyBridgeCachePath/package.json
    cp -v ${./package-lock.json} $out$jsPyBridgeCachePath/package-lock.json
  '';

  # use a patched pythonImportsCheckPhase
  # to call postPythonImportsCheck

  # no, this requires substitutions
  # nixpkgs/pkgs/development/interpreters/python/hooks/python-imports-check-hook.sh
  #source ${./python-imports-check-hook.sh}

  postInstall = ''
    echo patching pythonImportsCheckPhase
    s="$(type pythonImportsCheckPhase | tail -n +2)"
    if ! echo "$s" | grep -q "^    runHook prePythonImportsCheck"; then
      s="$(echo "$s" | sed 's/^{/{\n    runHook prePythonImportsCheck/')"
    fi
    if ! echo "$s" | grep -q "^    runHook postPythonImportsCheck"; then
      s="$(echo "$s" | sed 's/^}/    runHook postPythonImportsCheck\n}/')"
    fi
    eval "$s"
    #echo "patched pythonImportsCheckPhase:"; type pythonImportsCheckPhase
  '';

  # these files are created in pythonImportsCheckPhase
  # botasaurus will create these files in workdir
  # these files should not be created on "import botasaurus"
  # https://github.com/omkarcloud/botasaurus/issues/38

  postPythonImportsCheck = ''
    echo removing tempfiles from postPythonImportsCheck
    pushd $out >/dev/null
    rm -rf -v local_storage.json output profiles profiles.json tasks
    popd >/dev/null
  '';

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  # https://github.com/omkarcloud/botasaurus/blob/master/setup.py
  propagatedBuildInputs = with python3.pkgs; [
    psutil
    requests
    javascript
    joblib
    beautifulsoup4
    #chromedriver-autoinstaller
    cloudscraper
    selenium
    botasaurus-proxy-authentication
    packaging
  ] ++ [
    chromium
    chromedriver
  ];

  pythonImportsCheck = [ "botasaurus" ];

  meta = with lib; {
    description = "The All in One Web Scraping Framework";
    homepage = "https://github.com/omkarcloud/botasaurus";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "botasaurus";
  };
}
