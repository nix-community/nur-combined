{
  lib,
  python3Packages,
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
  webkitgtk_5_0,
}:
python3Packages.buildPythonApplication rec {
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
    webkitgtk_5_0
  ];

  pythonPath =
    [
      python3Packages.croniter
      python3Packages.humanize
      python3Packages.lxml
      python3Packages.markdown2
      python3Packages.pygobject3
      python3Packages.python-crontab
      python3Packages.ruamel-yaml
      python3Packages.sqlparse
    ]
    ++ [
      (python3Packages.buildPythonPackage rec {
        pname = "daltonlens";
        version = "0.1.5";
        format = "pyproject";
        src = python3Packages.fetchPypi {
          inherit pname version;
          hash = "sha256-T7fXlRdFtcVw5WURPqZhCmulUi1ZnCfCXgcLtTHeNas=";
        };
        nativeBuildInputs = [
          python3Packages.setuptools
          python3Packages.wheel
        ];
        propagatedBuildInputs = [
          python3Packages.numpy
          python3Packages.pillow
        ];
        pythonImportsCheck = [
          "daltonlens"
        ];
      })
      (
        if python3Packages ? python-jwt
        then python3Packages.python-jwt
        else
          python3Packages.buildPythonPackage rec {
            pname = "jwt";
            version = "1.3.1";
            src = fetchFromGitHub {
              owner = "GehirnInc";
              repo = "python-jwt";
              rev = "v${version}";
              hash = "sha256-N1J8yBVX/O+92cRp+q2gA2cFsd+C7JjUR9jo0VGoINg=";
            };
            propagatedBuildInputs = [
              python3Packages.cryptography
            ];
            nativeCheckInputs = [
              python3Packages.pytestCheckHook
              python3Packages.freezegun
              python3Packages.pytest
            ];
            pythonImportsCheck = [
              "jwt"
            ];
          }
      )
      (python3Packages.buildPythonPackage rec {
        pname = "lorem";
        version = "0.1.1";
        format = "setuptools";
        src = python3Packages.fetchPypi {
          inherit pname version;
          hash = "sha256-eF9BCaJB/CiR5ZcF6F0GX25tPtatkXUKjLVNTz5Z2TQ=";
        };
        pythonImportsCheck = [
          "lorem"
        ];
      })
      (python3Packages.buildPythonPackage rec {
        pname = "textstat";
        version = "0.7.3";
        format = "setuptools";
        src = python3Packages.fetchPypi {
          inherit pname version;
          hash = "sha256-YLY8+JSfRbuztCBeRBG7wc1m30wIrvElRYEcfm4k8BE=";
        };
        propagatedBuildInputs = [
          python3Packages.pyphen
          python3Packages.setuptools
        ];
        pythonImportsCheck = [
          "textstat"
        ];
        doCheck = false;
      })
      (python3Packages.buildPythonPackage rec {
        pname = "uuid6";
        version = "2022.10.25";
        format = "setuptools";
        src = python3Packages.fetchPypi {
          inherit pname version;
          hash = "sha256-ClaTXenBzo3YVZIluEVUnZSRfZ4krUscwjKO6lvgAQw=";
        };
        pythonImportsCheck = [
          "uuid6"
        ];
      })
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
