{ lib
, python3Packages
, fetchFromGitHub
, blueprint-compiler
, desktop-file-utils
, gobject-introspection
, meson
, ninja
, pkg-config
, wrapGAppsHook4
, gcr_4
, gtksourceview5
, libadwaita
, webkitgtk_6_0
, nix-update-script
}:

python3Packages.buildPythonApplication rec {
  pname = "devtoolbox";
  version = "1.1.1";

  format = "other";

  src = fetchFromGitHub {
    owner = "aleiepure";
    repo = "devtoolbox";
    rev = "v${version}";
    hash = "sha256-QFGEA+VhhRlvcch2AJrEzvRJGCSqtvZdMXWUvdAGkoU=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gcr_4
    gtksourceview5
    libadwaita
    webkitgtk_6_0
  ];

  propagatedBuildInputs = with python3Packages; [
    asn1crypto
    croniter
    cssbeautifier
    humanize
    jsbeautifier
    jsonschema
    lxml
    markdown2
    pygobject3
    (python-crontab.overrideAttrs (oldAttrs: {
      disabledTests = oldAttrs.disabledTests ++ [
        "test_19_frequency_at_month"
      ];
    }))
    python-jwt
    pytz
    qrcode
    ruamel-yaml
    sqlparse
    tzlocal
  ] ++ [
    (buildPythonPackage rec {
      pname = "daltonlens";
      version = "0.1.5";

      format = "pyproject";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-T7fXlRdFtcVw5WURPqZhCmulUi1ZnCfCXgcLtTHeNas=";
      };

      nativeBuildInputs = [
        setuptools
        setuptools-git
      ];

      propagatedBuildInputs = [
        numpy
        pillow
      ];

      pythonImportsCheck = [ "daltonlens" ];
    })

    (buildPythonPackage rec {
      pname = "python-lorem";
      version = "1.3.0.post1";

      format = "setuptools";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-aokLCuQq6iHpC90MLCcIQxeEArPyx1o6RU1224xZdxY=";
      };

      pythonImportsCheck = [ "lorem" ];
    })

    (buildPythonPackage rec {
      pname = "textstat";
      version = "0.7.3";

      format = "setuptools";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-YLY8+JSfRbuztCBeRBG7wc1m30wIrvElRYEcfm4k8BE=";
      };

      propagatedBuildInputs = [
        pyphen
      ];

      pythonImportsCheck = [ "textstat" ];

      doCheck = false;
    })

    (buildPythonPackage rec {
      pname = "uuid6";
      version = "2023.5.2";

      format = "setuptools";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-A8uX8lynsKxL6is6IF9mv+f1jTsXm7D3bh15RkRrYTM=";
      };

      pythonImportsCheck = [ "uuid6" ];
    })
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "devtoolbox";
    description = "Development tools at your fingertips";
    homepage = "https://github.com/aleiepure/devtoolbox";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder blueprint-compiler.version "0.8";
  };
}
