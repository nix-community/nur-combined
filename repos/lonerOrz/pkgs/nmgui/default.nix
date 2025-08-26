{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  wrapGAppsHook3,
  gobject-introspection,
  gtk4,
  glib,
  makeDesktopItem,
  copyDesktopItems,
  networkmanager,
}:
let
  nmcliPath = lib.getExe' networkmanager "nmcli";
  nmcli = python3Packages.buildPythonPackage rec {
    pname = "nmcli";
    version = "1.5.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "ushiboy";
      repo = "nmcli";
      tag = "v${version}";
      hash = "sha256-1gVj4WfTx1NcoyWA9OK5EyGze9hmrXV0Mq50C1S3bfM=";
    };

    build-system = with python3Packages; [
      setuptools
      wheel
    ];

    postPatch = ''
      substituteInPlace nmcli/_system.py \
        --replace-fail \
          "c = ['sudo', 'nmcli'] if self._use_sudo else ['nmcli']" \
          "c = ['sudo', '${nmcliPath}'] if self._use_sudo else ['${nmcliPath}']"
    '';

    meta = {
      description = "Python library for interacting with NetworkManager CLI";
      homepage = "https://github.com/ushiboy/nmcli";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
      maintainers = with lib.maintainers; [ lonerOrz ];
    };
  };

in
python3Packages.buildPythonApplication rec {
  pname = "nmgui";
  version = "1.0.0";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "s-adi-dev";
    repo = "nmgui";
    tag = "v${version}";
    hash = "sha256-HS/n40Ng8S5N14DtEH/upwlxdzwCoOEJA40EMdCcLw4=io";
  };

  nativeBuildInputs = [
    gobject-introspection
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk4
    glib
  ];

  dependencies = [
    python3Packages.pygobject3
    nmcli
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "nmgui";
      exec = "nmgui";
      icon = "network-wireless-symbolic";
      comment = "Network Manager GUI";
      desktopName = "nmgui";
      categories = [ "Network" ];
      startupNotify = true;
    })
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{libexec/nmgui,bin,share/applications}
    cp -r app/* $out/libexec/nmgui/
    runHook postInstall
  '';

  dontWrapGApps = true;

  postFixup = ''
    makeWrapper ${python3Packages.python.interpreter} $out/bin/nmgui \
      --add-flags "$out/libexec/nmgui/main.py" \
      --prefix PYTHONPATH : "$PYTHONPATH" \
       "''${gappsWrapperArgs[@]}"
  '';

  meta = {
    description = "Python library for interacting with NetworkManager CLI";
    homepage = "https://github.com/s-adi-dev/nmgui";
    mainProgram = "nmgui";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
