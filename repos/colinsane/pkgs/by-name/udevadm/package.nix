# standalone `udevadm`, built from the same src/version as `systemd`.
# notably, aims to support static building ala `nix-build -A pkgsStatic.udevadm`.
{
  buildPackages,
  gperf,
  jq,
  lib,
  libucontext,
  meson,
  ninja,
  pkg-config,
  stdenv,
  systemd,
}:
stdenv.mkDerivation {
  pname = "udevadm";
  inherit (systemd) version src;

  nativeBuildInputs = [
    gperf
    jq
    meson
    ninja
    pkg-config
    (buildPackages.python3.withPackages (ps: [ ps.jinja2 ]))
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isMusl [
    libucontext
  ];

  postPatch = ''
    patchShebangs tools src/*/*.py
  '';

  mesonFlags = [
    (lib.mesonOption "mode" "release")
    (lib.mesonOption "auto_features" "disabled")
    # sysconfdir is /etc, outside $out
    (lib.mesonBool "install-sysconfdir" false)
    (lib.mesonBool "link-udev-shared" false)
    (lib.mesonBool "build-static" stdenv.hostPlatform.isStatic)
    (lib.mesonBool "tests" false)
    (lib.mesonBool "man" false)
    (lib.mesonBool "html" false)
  ] ++ lib.optionals stdenv.hostPlatform.isMusl [
    (lib.mesonOption "libc" "musl")
    (lib.mesonBool "gshadow" false)
  ];

  # build only what `meson install --tags udev` will install (udevadm, its helpers, rules, units).
  preBuild = ''
    ninjaFlagsArray+=($(meson introspect --install-plan \
      | jq -r '.targets | to_entries[] | select(.value.tag == "udev") | .key' \
      | sed "s:^$PWD/::"))
  '';

  mesonInstallTags = [ "udev" ];

  # pkgsStatic propagates buildInputs (libucontext), which would otherwise become a runtime reference.
  postFixup = ''
    rm -f "$out/nix-support/propagated-build-inputs"
    rmdir --ignore-fail-on-non-empty "$out/nix-support" 2>/dev/null || true
  '';

  meta = {
    inherit (systemd.meta) homepage license;
    description = "udev management tool, built standalone from systemd";
    mainProgram = "udevadm";
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
  };
}
