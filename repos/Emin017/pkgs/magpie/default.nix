{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  gtk3,
  gdk-pixbuf,
  glib,
  fontconfig,
  libX11,
  webkitgtk_4_1,
  libsoup_3,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "magpie";
  version = "0.1.1226";

  src = fetchurl {
    url = "https://github.com/yetone/magpie-releases/releases/download/v${finalAttrs.version}/magpie-linux-amd64";
    hash = "sha256-EZfBZvitWJkpRFqQa79prAiE9G8f7aFl3UnoJwFwcPk=";
  };

  dontUnpack = true;

  # The prebuilt binary directly NEEDs the whole GTK/WebKit stack,
  # autoPatchelf points the interpreter and RPATH into the store
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    gtk3
    gdk-pixbuf
    glib
    fontconfig
    libX11
    webkitgtk_4_1
    libsoup_3
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/magpie
    runHook postInstall
  '';

  meta = {
    description = "One local gateway serving every AI agent's model";
    homepage = "https://usemagpie.ai";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "magpie";
  };
})
