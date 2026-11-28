# Droidloom: Android userspace in native Wayland windows.
#
# The host programs (supervisor, presenter, audio, GPU server, device broker,
# application catalog, doctor, CLI and package helper) are built from the
# pinned upstream source. The Android side (system/system_ext/product/vendor
# images plus the patched framework, SurfaceFlinger and native libraries) needs
# a sparse AOSP/Soong build with prebuilt base partitions and is not
# reproducible inside the Nix sandbox; it is taken from the matching upstream
# `droidloom-image` release package instead. Both come from the same release
# cycle (host source rev of 2026-11-27, image 0.1.0-52).
{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  glslang,
  makeWrapper,
  jq,
  zstd,
  gnutar,
  pipewire,
  wireplumber,
  libdrm,
  libgbm,
  mesa,
  libGL,
  wayland,
  wayland-protocols,
  libxkbcommon,
  vulkan-loader,
  systemd,
  util-linux,
  e2fsprogs,
  android-tools,
  iproute2,
  iptables,
  nftables,
  dbus,
  rsync,
  coreutils,
  gawk,
  polkit,
  testers,
  writeShellApplication,
  python3,
  curl,
  git,
  nix,
}:

let
  version = "0.1.0-unstable-2026-11-27";

  src = fetchFromGitHub {
    owner = "denialwm";
    repo = "droidloom";
    rev = "e6f18c47cb4fc8fbd160a128cd55f1c47ba048da";
    hash = "sha256-CJg5R5ZgRxRHKUczfDbxoQicnim8gd+XO4dMuUP0CfE=";
  };

  # Upstream publishes the Android image package for both architectures.
  # The x86_64 package carries the x86_64 Android images and Android-side
  # Droidloom components built by upstream's package workflow.
  imagePackage = fetchurl {
    url = "https://github.com/denialwm/droidloom/releases/download/packages/droidloom-image-0.1.0-52-x86_64.pkg.tar.zst";
    hash = "sha256-Lfk46L2D4mdvg2K87SbJ34+JhwLFN6PueDBeazf/Dgo=";
  };

  # Android ELF files target bionic and must not be rewritten by Nix's ELF
  # fixups. Keeping them in their own output also keeps autoPatchelf away from
  # them; the host package only links to this tree.
  image = stdenv.mkDerivation {
    pname = "droidloom-image";
    inherit version;
    src = imagePackage;
    nativeBuildInputs = [
      zstd
      gnutar
    ];
    dontUnpack = true;
    dontStrip = true;
    dontPatchELF = true;
    dontAutoPatchelf = true;
    # Android's init scripts use bionic shebangs; rewriting them would break
    # the guest userspace.
    dontPatchShebangs = true;

    installPhase = ''
      runHook preInstall
      mkdir -p unpack
      zstd -dc "$src" | tar -x -C unpack --no-same-owner
      mkdir -p "$out/lib" "$out/share/licenses"
      mv unpack/usr/lib/droidloom "$out/lib/droidloom"
      mv unpack/usr/share/licenses/droidloom-image "$out/share/licenses/droidloom-image"
      runHook postInstall
    '';

    meta = {
      description = "Droidloom Android system image and Android-side components";
      license = with lib.licenses; [
        gpl3Plus
        asl20
      ];
      platforms = [ "x86_64-linux" ];
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };

  hostCrates = [
    "droidloom-supervisor"
    "droidloom-wayland"
    "droidloom-applications"
    "droidloom-audio"
    "droidloom-gpu-server"
    "droidloom-devices"
    "droidloom-doctor"
    "droidloom-package-support"
  ];

  binaries = [
    "droidloomctl"
    "droidloomd"
    "droidloom-supervisor"
    "droidloom-wayland"
    "droidloom-applications"
    "droidloom-audio"
    "droidloom-gpu-server"
    "droidloom-devices"
    "droidloom-doctor"
  ];

  runtimePath = lib.makeBinPath [
    android-tools
    coreutils
    dbus
    e2fsprogs
    gawk
    iproute2
    iptables
    nftables
    pipewire
    polkit
    rsync
    systemd
    gnutar
    util-linux
    wireplumber
    zstd
  ];

  runtimeLibs = lib.makeLibraryPath [
    libdrm
    libgbm
    mesa
    wayland
    libxkbcommon
    pipewire
    vulkan-loader
    libGL
  ];
  pkg = rustPlatform.buildRustPackage {
    pname = "droidloom";
    inherit version src;

    cargoLock.lockFile = "${src}/Cargo.lock";

    nativeBuildInputs = [
      pkg-config
      glslang
      makeWrapper
      jq
    ];

    buildInputs = [
      pipewire
      libdrm
      libgbm
      mesa
      wayland
      wayland-protocols
      libxkbcommon
      vulkan-loader
      libGL
    ];

    # The upstream test suite also builds Android-side crates and needs a full
    # AOSP environment; the packaging gate is the host build itself.
    doCheck = false;

    cargoBuildFlags = map (crate: "-p ${crate}") hostCrates;

    # The host programs assume a distro filesystem (/usr/bin,
    # /usr/lib/droidloom, /usr/share/droidloom). Point those literals into this
    # store path. /etc/droidloom and /var/lib/droidloom stay absolute: they are
    # administrator-owned state written by `droidloomctl start`.
    # --replace-fail makes upstream drift fail the build instead of silently
    # shipping binaries that still reference /usr.
    postPatch = ''
      substituteInPlace \
        runtime/droidloom-contracts/src/gapps.rs \
        runtime/droidloom-package-support/src/main.rs \
        runtime/droidloom-supervisor/src/bin/droidloomctl.rs \
        runtime/droidloom-supervisor/src/lib.rs \
        runtime/droidloom-supervisor/src/linux_plan.rs \
        runtime/droidloom-supervisor/src/storage_backup.rs \
        --replace-fail '"/usr/lib/droidloom' "\"$out/lib/droidloom"

      substituteInPlace \
        runtime/droidloom-package-support/src/main.rs \
        runtime/droidloom-supervisor/src/bin/droidloomctl.rs \
        --replace-fail '"/usr/share/droidloom' "\"$out/share/droidloom"

      substituteInPlace \
        runtime/droidloom-package-support/src/main.rs \
        runtime/droidloom-supervisor/src/adb.rs \
        runtime/droidloom-supervisor/src/apk.rs \
        runtime/droidloom-supervisor/src/bin/droidloomctl.rs \
        runtime/droidloom-supervisor/src/control.rs \
        runtime/droidloom-supervisor/src/diagnostics.rs \
        runtime/droidloom-supervisor/src/games_driver.rs \
        runtime/droidloom-supervisor/src/ui_mode.rs \
        --replace-fail '"/usr/bin/' "\"$out/libexec/usrbin/"
    '';

    # rustPlatform's install hook expects a root package; the workspace is a
    # virtual manifest, so copy the selected binaries directly.
    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin" "$out/libexec/usrbin" "$out/share/droidloom" \
        "$out/lib/systemd/system" "$out/lib/systemd/user" "$out/share/licenses/droidloom"

      release=$(dirname "$(find target -type f -name droidloomctl -print -quit)")

      for binary in ${lib.escapeShellArgs binaries}; do
        install -Dm755 "$release/$binary" "$out/bin/$binary"
      done
      install -Dm755 "$release/droidloom-package-helper" \
        "$out/bin/droidloom-package-helper"

      # Absolute helper paths the host programs (and units) use.
      for helper in droidloom-package-helper droidloom-applications droidloomctl \
        droidloom-supervisor; do
        ln -s "../../bin/$helper" "$out/libexec/usrbin/$helper"
      done
      ln -s ${android-tools}/bin/adb "$out/libexec/usrbin/adb"
      ln -s ${coreutils}/bin/cat "$out/libexec/usrbin/cat"
      ln -s ${coreutils}/bin/env "$out/libexec/usrbin/env"
      ln -s ${coreutils}/bin/sleep "$out/libexec/usrbin/sleep"
      ln -s ${coreutils}/bin/sync "$out/libexec/usrbin/sync"
      ln -s ${coreutils}/bin/timeout "$out/libexec/usrbin/timeout"
      ln -s ${coreutils}/bin/true "$out/libexec/usrbin/true"
      ln -s ${polkit}/bin/pkexec "$out/libexec/usrbin/pkexec"
      ln -s ${systemd}/bin/systemctl "$out/libexec/usrbin/systemctl"
      ln -s ${systemd}/bin/systemd-run "$out/libexec/usrbin/systemd-run"
      ln -s ${util-linux}/bin/nsenter "$out/libexec/usrbin/nsenter"
      ln -s ${util-linux}/bin/runuser "$out/libexec/usrbin/runuser"

      # NixOS has no getent; the host only uses `getent passwd <uid>`.
      printf '%s\n' \
        "#!${stdenv.shell}" \
        "exec ${gawk}/bin/awk -F: -v key=\"\$2\" '\$3 == key { print; found = 1 } END { exit found ? 0 : 2 }' /etc/passwd" \
        > "$out/libexec/usrbin/getent"
      chmod +x "$out/libexec/usrbin/getent"

      # Android images and Android-side components (prebuilt, see the header).
      # Upstream's /usr/lib/droidloom also holds the package helper, so the
      # directory is assembled rather than symlinked wholesale.
      mkdir -p "$out/lib/droidloom"
      for entry in ${image}/lib/droidloom/*; do
        ln -s "$entry" "$out/lib/droidloom/$(basename "$entry")"
      done
      ln -s ../../bin/droidloom-package-helper \
        "$out/lib/droidloom/droidloom-package-helper"
      ln -s ${image}/share/licenses/droidloom-image "$out/share/licenses/droidloom-image"

      # The installer's cell template is generated by upstream from this spec.
      jq 'del(.host_uid, .data_dir, .denial_socket, .render_node, .runtime_dir)
          | .shared_storage_directories = []
          | .image_dir = "'$out'/lib/droidloom/images"
          | .vendor_image = "'$out'/lib/droidloom/images/images/vendor.raw.img"' \
        packaging/cell-spec-x86_64-u1000.json \
        | sed "s|/usr/lib/droidloom|$out/lib/droidloom|g" \
        > "$out/share/droidloom/cell-template.json"

      printf '%s\n' \
        '{' \
        '  "architecture": "x86_64",' \
        '  "release": 0,' \
        "  \"version\": \"$version\"" \
        '}' > "$out/share/droidloom/package.json"

      install -Dm644 packaging/environment.d/60-droidloom.conf \
        "$out/lib/environment.d/60-droidloom.conf"

      # Units point at this store path instead of /usr.
      for unit in packaging/systemd/system/*.service packaging/systemd/user/*.service \
        packaging/systemd/user/*.socket; do
        sed -e "s|/usr/bin/systemctl|${systemd}/bin/systemctl|g" \
            -e "s|/usr/lib/droidloom|$out/lib/droidloom|g" \
            -e "s|/usr/lib/environment.d|$out/lib/environment.d|g" \
            -e "s|/usr/bin/|$out/bin/|g" "$unit" \
          > "$out/lib/systemd/$(basename "$(dirname "$unit")")/$(basename "$unit")"
      done
      # The packaging variant reads the render-node environment written by setup.
      sed -e "s|/usr/bin/systemctl|${systemd}/bin/systemctl|g" \
          -e "s|/usr/lib/droidloom|$out/lib/droidloom|g" \
          -e "s|/usr/lib/environment.d|$out/lib/environment.d|g" \
          -e "s|/usr/bin/|$out/bin/|g" packaging/arch/droidloom.service \
        > "$out/lib/systemd/user/droidloom.service"

      install -Dm644 LICENSE "$out/share/licenses/droidloom/LICENSE"
      install -Dm644 THIRD_PARTY.md "$out/share/licenses/droidloom/THIRD_PARTY.md"

      runHook postInstall
    '';

    postFixup = ''
      for program in "$out"/bin/droidloom*; do
        wrapProgram "$program" \
          --prefix PATH : ${runtimePath} \
          --prefix LD_LIBRARY_PATH : ${runtimeLibs}
      done
    '';

    meta = {
      description = "Run Android applications as native Wayland windows";
      homepage = "https://github.com/denialwm/droidloom";
      license = lib.licenses.gpl3Plus;
      sourceProvenance = with lib.sourceTypes; [
        fromSource
        binaryNativeCode
      ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "droidloomctl";
    };
  };

  # The VM test driver cannot pass a physical GPU into the guest, so the test
  # variant also accepts QEMU's virtio-gpu. Production builds keep upstream's
  # hardware allowlist.
  virtioPkg = pkg.overrideAttrs (previousAttrs: {
    postPatch = ''
      patch -p1 < ${./virtio-gpu.patch}
    ''
    + previousAttrs.postPatch;
  });
in
pkg.overrideAttrs (previousAttrs: {
  passthru = (previousAttrs.passthru or { }) // {
    tests.nixos = testers.runNixOSTest (import ./test.nix { droidloom = virtioPkg; });
    updateScript = writeShellApplication {
      name = "update-droidloom";
      runtimeInputs = [
        python3
        curl
        git
        nix
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="droidloom"
        exec ${python3}/bin/python3 ${./update.py} "$@"
      '';
    };
  };
})
