{ lib
, python3Packages
, python-daltonlens
, python-jwt
, python-lorem
, python-textstat
, python-uuid6
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
  pyproject = false;

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

  propagatedBuildInputs = [
    python-daltonlens
    python-jwt
    python-lorem
    python-textstat
    python-uuid6
  ] ++ (with python3Packages; [
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
    pytz
    qrcode
    ruamel-yaml
    sqlparse
    tzlocal
  ]);

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
