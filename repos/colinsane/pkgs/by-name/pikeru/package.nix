{
  fetchFromGitHub,
  ffmpeg,
  gnused,
  gmp,
  lame,
  lib,
  libglvnd,
  libogg,
  libtheora,
  libvdpau,
  libxkbcommon,
  nix-update-script,
  openapv,
  pkg-config,
  poppler,
  rustPlatform,
  scdoc,
  soxr,
  sqlite,
  vulkan-loader,
  wayland,
  xvidcore,
  xz,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pikeru";
  version = "1.11";

  src = fetchFromGitHub {
    owner = "dvhar";
    repo = "pikeru";
    rev = finalAttrs.version;
    hash = "sha256-kQr6U8RpjcPPO8KqLA+DlpJoul6dw9OBPBbvUFjS+U4=";
  };

  cargoHash = "sha256-mVbPwNMSs2oNgPkMyoQU1qT+t8yuLhzydqJKaUb47X4=";

  nativeBuildInputs = [
    gnused
    pkg-config
    rustPlatform.bindgenHook
    scdoc
  ];

  buildInputs = [
    # TODO: does it really need all of these?
    # i guess most of them are thumbnail related.
    ffmpeg
    gmp
    lame
    libogg
    libtheora
    libvdpau
    openapv
    poppler
    soxr
    sqlite
    xvidcore
    xz
    # dlopen'd dependencies:
    libglvnd
    libxkbcommon
    vulkan-loader
    wayland
  ];

  # Force linking to libEGL, which is always dlopen()ed, and to
  # libwayland-client & libxkbcommon, which is dlopen()ed based on the
  # winit backend.
  # from <repo:nixos/nixpkgs:pkgs/by-name/uk/ukmm/package.nix>
  NIX_LDFLAGS = [
    "--push-state"
    "--no-as-needed"
    "-lEGL"
    "-lvulkan"
    "-lwayland-client"
    "-lxkbcommon"
    "--pop-state"
  ];

  # manual steps taken from the repo's PKGBUILD
  postInstall = ''
    install -dm755 "$out/share/man/man5"
    install -dm755 "$out/share/xdg-desktop-portal/portals"
    # install -Dm755 "target/release/pikeru" "$out/bin/pikeru"
    # install -Dm755 "target/release/portal" "$out/lib/xdg-desktop-portal-pikeru"
    install -Dm755 "xdg_portal/pikeru-wrapper.sh" "$out/share/xdg-desktop-portal-pikeru/pikeru-wrapper.sh"
    install -Dm755 "xdg_portal/postprocess.example.sh" "$out/share/xdg-desktop-portal-pikeru/postprocess.example.sh"
    install -Dm755 "xdg_portal/setconfig.sh" "$out/share/xdg-desktop-portal-pikeru/setconfig.sh"
    install -Dm755 "xdg_portal/unsetconfig.sh" "$out/share/xdg-desktop-portal-pikeru/unsetconfig.sh"
    install -Dm755 "indexer/img_indexer.py" "$out/share/xdg-desktop-portal-pikeru/img_indexer.py"
    install -Dm644 "xdg_portal/xdg-desktop-portal-pikeru.service" "$out/lib/systemd/user/xdg-desktop-portal-pikeru.service"
    install -Dm644 "xdg_portal/org.freedesktop.impl.portal.desktop.pikeru.service" "$out/share/dbus-1/services/org.freedesktop.impl.portal.desktop.pikeru.service"
    scdoc < "xdg_portal/xdg-desktop-portal-pikeru.5.scd" > "$out/share/man/man5/xdg-desktop-portal-pikeru.5"
    sed "s/@cur_desktop@//" "xdg_portal/pikeru.portal.in" > "$out/share/xdg-desktop-portal/portals/pikeru.portal"

  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "File picker with semantic search and image viewer";
    homepage = "https://github.com/dvhar/pikeru";
    license = licenses.mit;
    maintainers = with maintainers; [ colinsane ];
  };
})
