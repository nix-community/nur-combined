{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication {
  pname = "samloader";
  version = "unstable-2024-02-10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "martinetd";
    repo = "samloader";
    rev = "0d724ce27b88915f61111313ce406a12c5c25a4a";
    hash = "sha256-+Z5qALmuPHbLA5g3+uEUDGYLUV4jcrhHG9P+V4hgcs4=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [
    "samloader"
  ];

  propagatedBuildInputs = with python3.pkgs; [
    tqdm
    pycryptodomex
    requests
  ];

  meta = {
    description = "Download Samsung firmware from official servers";
    homepage = "https://github.com/martinetd/samloader";
    license = lib.licenses.gpl3Only;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "samloader";
    platforms = lib.platforms.all;
  };
}
