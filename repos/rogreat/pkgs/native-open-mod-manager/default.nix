{
  fetchFromGitHub,
  gobject-introspection,
  lib,
  libadwaita,
  libnotify,
  python3Packages,
  wrapGAppsHook4,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "native-open-mod-manager";
  version = "0.10.1";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "Allexio";
    repo = "nomm";
    tag = finalAttrs.version;
    hash = "sha256-0+374FbaTkAjXf2+anZtckz/Ozz/B47UQVRCQTZCqus=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
  ];

  # https://github.com/Allexio/nomm/blob/main/build/flatpak/build-flatpak.sh
  dependencies = [
    libadwaita
    libnotify
  ]
  ++ (with python3Packages; [
    pygobject3
    pyyaml
    rarfile
    requests
    vdf
  ]);

  # https://github.com/Allexio/nomm/blob/main/build/flatpak/com.nomm.Nomm.yaml
  postInstall = ''
    install src/main.py -Dm544 $out/bin/nomm
    install build/flatpak/com.nomm.Nomm.desktop -D $out/share/applications/com.nomm.Nomm.desktop
    install assets/nomm.png -D $out/share/icons/hicolor/64x64/apps/com.nomm.Nomm.png
    mkdir -p $out/${python3Packages.python.sitePackages}
    cp -r src -T $out/${python3Packages.python.sitePackages}
    cp -r assets $out/${python3Packages.python.sitePackages}
    cp -r default_game_configs $out/${python3Packages.python.sitePackages}
  '';

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=(
        "''${gappsWrapperArgs[@]}"
        --prefix PYTHONPATH : "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
    )
  '';

  meta = {
    description = "Native Open Mod Manager ";
    homepage = "https://github.com/Allexio/nomm";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "nomm";
    platforms = lib.platforms.linux;
    broken = true;
  };
})
