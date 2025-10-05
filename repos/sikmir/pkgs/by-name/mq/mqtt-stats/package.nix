{
  lib,
  fetchFromGitHub,
  python3Packages,
  gtk3,
  gobject-introspection,
  wrapGAppsHook,
}:

python3Packages.buildPythonApplication {
  pname = "mqtt-stats";
  version = "0-unstable-2023-07-13";
  format = "other";

  src = fetchFromGitHub {
    owner = "gambitcomminc";
    repo = "mqtt-stats";
    rev = "cd7378df22dce40d4a790e4d4b58b187c141b1dc";
    hash = "sha256-LkgRubf+Iy+qmoLudGzHjbtzOyKJlxmj5OqxxCIM/2o=";
  };

  postPatch = ''
    substituteInPlace mqtt-stats.py \
      --replace-fail "glade_path = dir_path" "glade_path = \"$out/share/mqtt-stats\""
  '';

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook
  ];

  dependencies = with python3Packages; [
    paho-mqtt
    pygobject3
    gtk3
  ];

  installPhase = ''
    install -Dm755 mqtt-stats.py $out/bin/mqtt-stats
    install -Dm644 mqtt-stats.glade -t $out/share/mqtt-stats
  '';

  meta = {
    description = "MQTT Topic Statistics";
    homepage = "https://github.com/gambitcomminc/mqtt-stats";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
