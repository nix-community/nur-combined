# packaging status (2025-12-13):
# - it builds
# - the `pikeru` binary seems to work
# - the `portal` binary crashes on launch:
#   > thread 'main' (884208) panicked at src/portal.rs:171:83:
#   > called `Result::unwrap()` on an `Err` value: SqliteFailure(Error { code: DiskFull, extended_code: 13 }, Some("database or disk is full"))
#   > stack backtrace:
#   >    0: __rustc::rust_begin_unwind
#   >    1: core::panicking::panic_fmt
#   >    2: core::result::unwrap_failed
#   >    3: portal::IdxManager::new
#   >    4: tokio::runtime::park::CachedParkThread::block_on
#   >    5: tokio::runtime::context::runtime::enter_runtime
#   >    6: tokio::runtime::runtime::Runtime::block_on
#   >    7: portal::main
{
  bash,
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
  python3,
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

  # this is nasty; should work with upstream to find a better solution.
  # pikeru as portal reads a ~/.config file, then execs a helper referenced from that file.
  # if the ~/.config file doesn't exist, then it populates it with defaults.
  # solution: populate the high-priority launcher to $out/share/...
  # and the fallback to /run/current-system/sw/share/...
  # but both of these may drift.
  postPatch = ''
    substituteInPlace src/portal.rs \
      --replace-fail '/usr/local/share' '/run/current-system/sw/share' \
      --replace-fail '/usr/share' "${placeholder "out"}/share"
  '';

  nativeBuildInputs = [
    gnused
    pkg-config
    rustPlatform.bindgenHook
    scdoc
  ];

  buildInputs = [
    # TODO: does it really need all of these?
    # i guess most of them are thumbnail related.
    bash  #< for runtime scripts
    ffmpeg
    gmp
    lame
    libogg
    libtheora
    libvdpau
    openapv
    poppler
    (python3.withPackages (ps: with ps; [
      # for $out/share/xdg-desktop-portal-pikeru/img_indexer.py,
      # though unclear if img_indexer.py is actually used
      requests
    ]))
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
