{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  substituteAll,
  setuptools,
  cs3apis,
  grpcio,
  grpcio-tools,
  flask,
  pyjwt,
  requests,
  more-itertools,
  prometheus-flask-exporter,
  waitress,
  werkzeug,
  nix-update-script,
}:
buildPythonApplication rec {
  pname = "wopiserver";
  version = "10.5.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cs3org";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-KJhNCcYTADALKk8mIUyTjfFglYSg15ZcQcAVAuBa+AU=";
  };

  postPatch =
    let
      pyproject = substituteAll {
        src = ./pyproject.toml;
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

  buildInputs = [ setuptools ];

  propagatedBuildInputs = [
    cs3apis
    grpcio
    grpcio-tools
    flask
    pyjwt
    requests
    more-itertools
    prometheus-flask-exporter
    waitress
    werkzeug
  ];

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
  };
}
