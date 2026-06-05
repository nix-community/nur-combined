{
  bash,
  fetchFromGitLab,
  gcr,
  gitUpdater,
  glib,
  gnome-desktop,
  gnome-shell,
  gtk3,
  json-glib,
  lib,
  libgudev,
  libhandy,
  libjson,
  libxkbcommon,
  linux-pam,
  meson,
  networkmanager,
  ninja,
  phoc,
  pkg-config,
  python3,
  squeekboard ? null,
  stdenv,
  systemd,
  upower,
  wayland,
  wayland-scanner,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "phog";
  version = "0.1.7";

  src = fetchFromGitLab {
    owner = "mobian1";
    repo = "phog";
    rev = finalAttrs.version;
    hash = "sha256-7kw/X7gtSrq6XUqtPPO8ahkIqxPUrU4JSJhLMG8iIS8=";
  };

  patches = [
    ./sway-compat.patch
  ];

  postPatch = ''
    patchShebangs build-aux/post_install.py
    sed -i /phog_plugins_dir/d build-aux/post_install.py
    substituteInPlace src/greetd.c \
      --replace-fail '/usr/share/wayland-sessions' '/run/current-system/sw/share/wayland-sessions/' \
      --replace-fail '/usr/share/xsessions' '/run/current-system/sw/share/xsessions'
  '' + lib.optionalString (squeekboard == null) ''
    substituteInPlace data/phog.in \
      --replace-fail " & squeekboard" ""
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ bash squeekboard ]}
      --prefix XDG_DATA_DIRS : "${gnome-shell}/share/gsettings-schemas/${gnome-shell.name}"
    )
  '';

  mesonFlags = [ "-Dcompositor=${lib.getExe phoc}" ];

  depsBuildBuild = [
    pkg-config
  ];

  buildInputs = [
    gcr
    glib
    gnome-desktop
    gtk3
    libgudev
    libjson
    json-glib
    libhandy
    networkmanager
    linux-pam
    systemd
    upower
    wayland
    libxkbcommon
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    glib
    wayland-scanner
    wrapGAppsHook3
  ];

  passthru.updateScript = gitUpdater {};

  meta = {
    description = "Greetd-compatible greeter for mobile phones";
    homepage = "https://gitlab.com/mobian1/phog/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
})
