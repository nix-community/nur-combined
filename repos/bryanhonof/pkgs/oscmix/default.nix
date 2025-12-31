{
  lib,
  stdenv,
  fetchFromGitHub,

  glib,
  pkg-config,
  wrapGAppsHook3,

  alsa-lib,
  gtk3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "oscmix";
  version = "main";

  src = fetchFromGitHub {
    owner = "michaelforney";
    repo = "oscmix";
    rev = finalAttrs.version;
    hash = "sha256-b/FzAyTnQJ2t9TdcfEuOhsMixSa1TeYjKXCtyfkG7zs=";
  };

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  nativeBuildInputs = [
    glib
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    gtk3
  ];

  installPhase = ''
    runHook preInstall
    install -Dm 0755 gtk/oscmix-gtk oscmix alsarawio alsaseqio -t $out/bin/
    install -Dm 0644 doc/oscmix.1 -t $out/share/man/man1/
    install -Dm 0444 gtk/oscmix.gschema.xml -t $out/share/glib-2.0/schemas/
    glib-compile-schemas $out/share/glib-2.0/schemas/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Mixer for RME Fireface UCX II";
    homepage = "https://github.com/michaelforney/oscmix";
    license = licenses.free;
    maintainers = with maintainers; [ bryanhonof ];
    platforms = platforms.linux;
    mainProgram = "oscmix";
  };
})
