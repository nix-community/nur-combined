{
  lib,
  stdenv,
  fetchFromGitHub,
  libadwaita,
  pkg-config,
  meson,
  ninja,
  gjs,
  gobject-introspection,
  gtk4,
  desktop-file-utils,
  glib,
  blueprint-compiler,
  libportal,
  xdp-tools,
  gettext,
  wrapGAppsHook,
  gst_all_1
}:

stdenv.mkDerivation rec {
  pname = "dosage";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "diegopvlk";
    repo = "Dosage";
    rev = "v1.6.3";
    hash = "sha256-RjF+untlhejyALj2juHWcYfEIcg7MDYNyCL3mFtyZMc=";
  };

  nativeBuildInputs = [ pkg-config meson ninja desktop-file-utils blueprint-compiler libportal gjs gobject-introspection xdp-tools gettext glib gtk4 libadwaita wrapGAppsHook gst_all_1.gstreamer ];

  buildInputs = [ glib gtk4 libadwaita ];

  preFixup = ''
    sed -e '2iimports.package._findEffectiveEntryPointName = () => "io.github.diegopvlk.Dosage"' \
      -i $out/bin/io.github.diegopvlk.Dosage
  '';
  
  meta = with lib; {
    description = "Medication tracker for Linux";
    homepage = "https://github.com/diegopvlk/Dosage";
    license = licenses.gpl3Only;
    #maintainers = with maintainers; [ mich-adams ];
    platforms = platforms.linux;
    mainProgram = "dosage";
  };
}
