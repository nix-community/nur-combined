{ lib
, python3
, fetchFromGitHub
, npmlock2nix
}:

let

  node_modules = npmlock2nix.node_modules {
    # FIXME src should be optional
    src = ./.;
    #symlinkNodeModules = false;
    packageJson = ./package.json;
    packageLockJson = ./package-lock.json;
  };

in

python3.pkgs.buildPythonApplication rec {
  pname = "botasaurus-proxy-authentication";
  # https://pypi.org/project/botasaurus-proxy-authentication/
  version = "1.0.0"; # 2023-12-23
  pyproject = true;

  src = fetchFromGitHub {
    owner = "omkarcloud";
    repo = "botasaurus-proxy-authentication";
    rev = "cd249aba69bf62fdc2e2d4ff59dfc76d7e05ca19";
    hash = "sha256-hiwZhudchb3inSddTMq6beyPtoSNEUAMyQOjmpUl/eQ=";
  };

  # custom env added in pkgs/python3/pkgs/javascript/javascript.nix
  # https://github.com/extremeheat/JSPyBridge/issues/117
  # site-packages should be treated as read-only
  jsPyBridgeCacheEnv = "JS_PY_BRIDGE_CACHE";

  # TODO better place than /cache? /lib? /share? /opt?
  jsPyBridgeCachePath = "/cache/js-py-bridge";

  # env must be set before "from javascript import require"
  postPatch = ''
    substituteInPlace botasaurus_proxy_authentication/__init__.py \
      --replace \
        "from javascript import require" \
        $'import os\nos.environ["'$jsPyBridgeCacheEnv'"] = "'$out$jsPyBridgeCachePath$'"\nfrom javascript import require' \
  '';

  postBuild = ''
    mkdir -p $out$jsPyBridgeCachePath
    ln -s -v ${node_modules}/node_modules $out$jsPyBridgeCachePath/node_modules
    cp -v ${./package.json} $out$jsPyBridgeCachePath/package.json
    cp -v ${./package-lock.json} $out$jsPyBridgeCachePath/package-lock.json
  '';

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  /*
  # fix tests
  preBuild = ''
    export HOME=$TMP
  '';
  */

  propagatedBuildInputs = with python3.pkgs; [
    javascript
  ];

  pythonImportsCheck = [ "botasaurus_proxy_authentication" ];

  meta = with lib; {
    description = "Proxy Server with support for SSL, proxy authentication and upstream proxy";
    homepage = "https://github.com/omkarcloud/botasaurus-proxy-authentication";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "botasaurus-proxy-authentication";
  };
}
