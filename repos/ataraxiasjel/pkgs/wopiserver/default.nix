{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  replaceVars,
  setuptools,
  cs3client,
  cygrpc,
  flask,
  grpcio-tools,
  grpcio,
  more-itertools,
  prometheus-flask-exporter,
  pyjwt,
  pyopenssl,
  requests,
  waitress,
  nix-update-script,
}:
buildPythonApplication rec {
  pname = "wopiserver";
  version = "11.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cs3org";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ANbgJeq48/M3dJPGMGZ2Fn+cCuLEbKEv7Z+94G6xONo=";
  };

  postPatch =
    let
      pyproject = replaceVars ./pyproject.toml {
        inherit version;
      };
    in
    ''
      ln -s ${pyproject} pyproject.toml
      substituteInPlace src/wopiserver.py --replace-warn \
        "WOPISERVERVERSION = 'git'" "WOPISERVERVERSION = '${version}'" \
        --replace-fail "if __name__ == '__main__':" "def main():" \
        --replace-fail "/etc/wopi/wopiserver.defaults.conf" "$out/etc/wopi/wopiserver.defaults.conf"
      substituteInPlace wopiserver.conf --replace-fail \
        "/etc/wopi" "$out/etc/wopi"
    '';

  build-system = [ setuptools ];

  dependencies = [
    cs3client
    cygrpc
    flask
    grpcio
    grpcio-tools
    more-itertools
    prometheus-flask-exporter
    pyjwt
    pyopenssl
    requests
    waitress
  ];

  doCheck = false;

  preInstall = ''
    mkdir -p $out/etc/wopi
    cp wopiserver.conf $out/etc/wopi/wopiserver.defaults.conf
    echo "testsecret" > $out/etc/wopi/wopisecret
    echo "testsecret" > $out/etc/wopi/iopsecret
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A vendor-neutral application gateway compatible with the WOPI specifications.";
    homepage = "https://github.com/cs3org/wopiserver";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "wopiserver";
  };
}
