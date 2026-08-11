{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "prometheus-qbittorrent-exporter";
  version = "1.5.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "esanchezm";
    repo = "prometheus-qbittorrent-exporter";
    #rev = version;
    # https://github.com/esanchezm/prometheus-qbittorrent-exporter/issues/41
    # add option EXPORTER_ADDRESS
    rev = "a58d6a83aa4e4f775ebce2c1932f52ba78a1be24";
    hash = "sha256-xqjiKh3YmuUAhdGiyDWD48sirbjL+RnkOedk6Hb6r2g=";
  };

  # unpin dependencies
  postPatch = ''
    sed -i -E 's/^    "([^"]+)>=[^"]+",/    "\1",/' pyproject.toml
  '';

  nativeBuildInputs = [
    python3.pkgs.pdm-backend
  ];

  propagatedBuildInputs = with python3.pkgs; [
    prometheus-client
    python-json-logger
    qbittorrent-api
  ];

  pythonImportsCheck = [ "qbittorrent_exporter" ];

  meta = with lib; {
    description = "A prometheus exporter for qbittorrent written in Python";
    homepage = "https://github.com/esanchezm/prometheus-qbittorrent-exporter";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "prometheus-qbittorrent-exporter";
  };
}
