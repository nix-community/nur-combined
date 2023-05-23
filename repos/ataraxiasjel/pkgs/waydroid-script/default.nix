{ lib
, python3Packages
, fetchFromGitHub
, substituteAll
, lzip
, sqlite
, util-linux
}:
python3Packages.buildPythonApplication rec {
  pname = "waydroid-script";
  version = "2023.05.13";

  src = fetchFromGitHub {
    repo = "waydroid_script";
    owner = "casualsnek";
    rev = "0abfc4ef4b964cdf3831ae79843f1d4eb44a5dc4";
    hash = "sha256-ZUSJdqO3bZj5BPvECkm8n/wiOjccZaB97ZGK+1way1E=";
  };

  propagatedBuildInputs = with python3Packages; [
    tqdm
    requests
    lzip
    sqlite
    util-linux
  ];

  postPatch =
    let
      setup = substituteAll {
        src = ./setup.py;
        desc = meta.description;
        inherit pname version;
      };
    in
    ''
      ln -s ${setup} setup.py
    '';

  meta = with lib; {
    description = "Python Script to add libraries to waydroid";
    homepage = "https://github.com/casualsnek/waydroid_script";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
