{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3,
  wrapGAppsHook4,
  gobject-introspection,
  gtk4-layer-shell,
  gtk4,
  cairo,
}:

python3.pkgs.buildPythonApplication (self: {
  pname = "driftmap";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rywby-dot";
    repo = "driftwm-minimap";
    tag = "v${self.version}";
    hash = "sha256-lXS95QW7HCiQqjIkyTjv48riEYX6o5IXbKNpKivDzqE=";
  };

  build-system = with python3.pkgs; [
    hatchling
  ];
  dependencies = with python3.pkgs; [
    pygobject3
    pycairo
  ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
  ];
  buildInputs = [
    gtk4
    gtk4-layer-shell
    cairo
  ];

  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --set LD_PRELOAD "${gtk4-layer-shell}/lib/libgtk4-layer-shell.so"
    )
  '';

  passthru.update-script = nix-update-script {};

  meta = lib.mkMeta {
    description = "Layer Shell's OVERLAY layer Minimap for Driftwm";
    license = "mit";
    homepage = "https://github.com/rywby-dot/driftwm-minimap";
    mainProgram = "driftmap";
  };
})
