{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "vidgear";
  version = "0.3.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "abhiTronix";
    repo = "vidgear";
    rev = "vidgear-${version}";
    hash = "sha256-y2+IOGUTD5w8hXO55ZdnsPkB31ZE7K81L+CSTlUwzSk=";
  };

  # latest_version requires internet access
  postPatch = ''
    substituteInPlace setup.py \
      --replace-warn \
        'def latest_version(package_name):' \
        "$(
          echo 'def latest_version(_):'
          echo '    return ""'
          echo
          echo 'def _latest_version(package_name):'
        )"
  '';

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    cython
    numpy
    requests
    colorlog
    tqdm
    opencv4
  ];

  pythonImportsCheck = [ "vidgear" ];

  meta = with lib; {
    description = "high-performance video processing framework";
    homepage = "https://github.com/abhiTronix/vidgear";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
