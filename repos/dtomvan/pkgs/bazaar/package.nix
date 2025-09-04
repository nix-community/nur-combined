{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  wrapGAppsHook4,
  nix-update-script,

  appstream,
  bubblewrap,
  flatpak,
  glycin-loaders,
  gtk4,
  json-glib,
  libadwaita,
  libdex,
  libglycin,
  libsoup_3,
  libxmlb,
  libyaml,

  blueprint-compiler,
  desktop-file-utils,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bazaar";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "kolunmi";
    repo = "bazaar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4nJwwH2BHry4LsV89ZqhmFafwKt+VpaeRpD97Ywtyig=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    appstream
    flatpak
    gtk4
    json-glib
    libadwaita
    (libdex.overrideAttrs {
      version = "0.11.1";
      src = fetchurl {
        url = "mirror://gnome/sources/libdex/0.11/libdex-0.11.1.tar.xz";
        hash = "sha256-lCUKLYPm9z06yJcvGkOAFSNqRltWywBeDmv7nUlIc58=";
      };
    })
    (libglycin.overrideAttrs (
      _final: prev: {
        patches = (if prev ? patches then prev.patches else [ ]) ++ [
          # Otherwise the PATH will be cleared and bwrap could not be found
          ./libglycin-no-clearenv.patch
        ];
      }
    ))
    libsoup_3
    libxmlb
    libyaml
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "$out/bin:${lib.makeBinPath [ bubblewrap ]}"
      --prefix XDG_DATA_DIRS : "${glycin-loaders}/share"
    )
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "New FlatHub-first app store for GNOME";
    homepage = "https://github.com/kolunmi/bazaar";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "bazaar";
    platforms = lib.platforms.linux;
  };
})
