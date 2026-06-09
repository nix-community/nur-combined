{
  lib,
  python3,
  fetchFromGitHub,
  fw-fanctrl,
  makeWrapper,
  wrapGAppsHook3,
  gobject-introspection,
  libappindicator-gtk3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "fw-fanctrl-ui";
  version = "0-unstable-2026-03-05";

  src = fetchFromGitHub {
    owner = "waicool20";
    repo = "fw-fanctrl-ui";
    rev = "6cf5e5e3e943966a51e156a2ebc74022b3383b08";
    hash = "sha256-374o4sc5r4C9IJew68F30eHJXFteThTvdFwBKr8XdL4=";
  };

  format = "other";

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    libappindicator-gtk3
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pystray
    pillow
  ];

  postPatch = ''
    substituteInPlace fw-fanctrl-ui.py \
      --replace 'Image.open("icon/64.png")' 'Image.open("'$out'/share/fw-fanctrl-ui/icon/64.png")' \
      --replace 'Image.open("icon/offline.png")' 'Image.open("'$out'/share/fw-fanctrl-ui/icon/offline.png")' \
      --replace '["fw-fanctrl"' '["${fw-fanctrl}/bin/fw-fanctrl"'
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/fw-fanctrl-ui/icon
    cp fw-fanctrl-ui.py $out/share/fw-fanctrl-ui/
    cp icon/*.png $out/share/fw-fanctrl-ui/icon/
    cp favicon.ico $out/share/fw-fanctrl-ui/

    makeWrapper ${python3.interpreter} $out/bin/fw-fanctrl-ui \
      --add-flags "$out/share/fw-fanctrl-ui/fw-fanctrl-ui.py" \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [ fw-fanctrl ]}

    install -Dm644 fw-fanctrl-ui.desktop $out/share/applications/fw-fanctrl-ui.desktop
    substituteInPlace $out/share/applications/fw-fanctrl-ui.desktop \
      --replace 'Exec=/usr/bin/python3 fw-fanctrl-ui.py' 'Exec=fw-fanctrl-ui' \
      --replace 'Icon=/opt/fw-fanctrl-ui/favicon.ico' "Icon=$out/share/fw-fanctrl-ui/favicon.ico" \
      --replace 'Path=/opt/fw-fanctrl-ui/' ""

    runHook postInstall
  '';

  meta = with lib; {
    description = "Tray icon for fw-fanctrl";
    homepage = "https://github.com/waicool20/fw-fanctrl-ui";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
    mainProgram = "fw-fanctrl-ui";
  };
}
