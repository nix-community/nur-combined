{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, cargo
, desktop-file-utils
, appstream-glib
, meson
, ninja
, pkg-config
, reuse
, rustc
, m4
, wrapGAppsHook4
, glib
, gtk4
, gtk3
, gst_all_1
, libadwaita
, dbus
}:

stdenv.mkDerivation rec {
  pname = "vaults";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "mpobaschnig";
    repo = pname;
    rev = version;
    hash = "sha256-x7NoYQ+ol/j8LMazL4A0jDi/I4ajRNUzOpShLB0eHUg=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-fDUsbeJzgqjvNCNce1FnvvqZfXu0X5Knpan4Q+PYe+Q=";
  };

  postPatch = ''
    patchShebangs build-aux
  '';

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    meson
    ninja
    pkg-config
    reuse
    m4
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    cargo
    rustc
    gtk3.out # Builtin meson script need to run gtk-update-icon-cache
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    dbus
  ];

  meta = with lib; {
    homepage = "https://github.com/mpobaschnig/vaults";
    description = "Keep important files safe";
    maintainers = with maintainers; [ pokon548 ];
    mainProgram = pname;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}