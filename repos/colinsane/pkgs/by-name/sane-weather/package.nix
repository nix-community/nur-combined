{
  glib-networking,
  gobject-introspection,
  libgweather,
  python3,
  stdenv,
  wrapGAppsNoGuiHook,
}:

let
  pyEnv = python3.withPackages (ps: [
    ps.pygobject3
  ]);
in
stdenv.mkDerivation {
  pname = "sane-weather";
  version = "0.1";
  src = ./.;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsNoGuiHook
  ];

  buildInputs = [
    glib-networking
    libgweather
    pyEnv
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp sane-weather "$out/bin"
    runHook postInstall
  '';
}
