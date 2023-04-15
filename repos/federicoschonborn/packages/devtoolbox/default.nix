{
  lib,
  fetchFromGitHub,
  desktop-file-utils,
  gobject-introspection,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  gtksourceview5,
  libadwaita,
  python3,
  webkitgtk_6_0,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "devtoolbox";
  version = "1.0.2";

  format = "other";

  src = fetchFromGitHub {
    owner = "aleiepure";
    repo = "devtoolbox";
    rev = "v${version}";
    hash = "sha256-NirgCBZW/bgJz5sVioe3gmpDgOtqwxsFD9FMA8kb2Uw=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    gtksourceview5
    libadwaita
    webkitgtk_6_0
  ];

  pythonPath =
    [
      python3.pkgs.croniter
      python3.pkgs.humanize
      python3.pkgs.lxml
      python3.pkgs.markdown2
      python3.pkgs.pygobject3
      python3.pkgs.python-crontab
      python3.pkgs.python-jwt
      python3.pkgs.ruamel-yaml
      python3.pkgs.sqlparse
    ]
    ++ [
      (
        python3.pkgs.daltonlens or python3.pkgs.buildPythonPackage rec {
          pname = "daltonlens";
          version = "0.1.5";
          format = "pyproject";
          src = python3.pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-T7fXlRdFtcVw5WURPqZhCmulUi1ZnCfCXgcLtTHeNas=";
          };
          nativeBuildInputs = [
            python3.pkgs.setuptools
            python3.pkgs.wheel
          ];
          propagatedBuildInputs = [
            python3.pkgs.numpy
            python3.pkgs.pillow
          ];
          pythonImportsCheck = [
            "daltonlens"
          ];
        }
      )
      (
        python3.pkgs.lorem or python3.pkgs.buildPythonPackage rec {
          pname = "lorem";
          version = "0.1.1";
          format = "setuptools";
          src = python3.pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-eF9BCaJB/CiR5ZcF6F0GX25tPtatkXUKjLVNTz5Z2TQ=";
          };
          pythonImportsCheck = [
            "lorem"
          ];
        }
      )
      (
        python3.pkgs.textstat or python3.pkgs.buildPythonPackage rec {
          pname = "textstat";
          version = "0.7.3";
          format = "setuptools";
          src = python3.pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-YLY8+JSfRbuztCBeRBG7wc1m30wIrvElRYEcfm4k8BE=";
          };
          propagatedBuildInputs = [
            python3.pkgs.pyphen
            python3.pkgs.setuptools
          ];
          pythonImportsCheck = [
            "textstat"
          ];
          doCheck = false;
        }
      )
      (
        python3.pkgs.uuid6 or python3.pkgs.buildPythonPackage rec {
          pname = "uuid6";
          version = "2022.10.25";
          format = "setuptools";
          src = python3.pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-ClaTXenBzo3YVZIluEVUnZSRfZ4krUscwjKO6lvgAQw=";
          };
          pythonImportsCheck = [
            "uuid6"
          ];
        }
      )
    ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Development tools at your fingertips";
    homepage = "https://github.com/aleiepure/devtoolbox";
    license = licenses.gpl3Plus;
  };
}
