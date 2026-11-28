{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  cmake,
  ninja,
  pkg-config,
  python3,
  makeBinaryWrapper,
  bison,
  patch,
  zstd,
  wayland,
  wayland-scanner,
  wayland-protocols,
  libxkbcommon,
  pixman,
  freetype,
  libpng,
  openssl,
  vulkan-loader,
  vulkan-headers,
  libglvnd,
  libGLU,
  libxcb,
  pkgsCross,
  wine64Packages,
  nix-update-script,
  writeShellApplication,
  git,
  gnused,
  cargo,
  rustc,
  stdenvNoCC,
  cacert,
}:

let
  ravenSrc = fetchFromGitHub {
    owner = "mirkobrombin";
    repo = "raven";
    rev = "82b2c9f9afcbd9b50591b57215f4c1d0d785a730";
    hash = "sha256-Kb2s3z64q1MZSLEag7k06hxRkzJFUP7IT64ZGjMDVLE=";
  };

  # native/waits depends on `loom` (only under cfg(loom), which the build never
  # enables), so cargo still needs the crate available in its registry.
  waitsCargoDeps = stdenvNoCC.mkDerivation {
    pname = "raven-waits-cargo-deps";
    version = "0.1.0";
    src = ravenSrc;
    nativeBuildInputs = [
      cargo
      cacert
    ];
    env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    dontConfigure = true;
    dontInstall = true;
    dontFixup = true;
    buildPhase = ''
      runHook preBuild
      export CARGO_HOME=$TMPDIR/cargo-home
      cd native/waits
      cargo vendor --locked "$out"
      runHook postBuild
    '';
    outputHashMode = "recursive";
    outputHash = "sha256-GlhrOuytOez526o2HhOXzXkf53ozwR3yH1nMDtM02vQ=";
  };

  # Pinned guest/installer inputs from Raven's provision scripts / backends.json.
  dxvk = fetchurl {
    url = "https://github.com/doitsujin/dxvk/releases/download/v3.2/dxvk-3.2.tar.gz";
    hash = "sha256-F0Se0hYCN3lxKJ6ymEdQaZglrBusO7+iQmsrug81VpI=";
  };

  vkd3dProton = fetchurl {
    url = "https://github.com/HansKristian-Work/vkd3d-proton/releases/download/v3.1/vkd3d-proton-3.1.tar.zst";
    hash = "sha256-uF6oIZtxCTo5JJE916rmFyMz3AwGmYPtUQgW1n8CEgs=";
  };

  # Source archives the provisioning scripts record alongside the binaries.
  # backends.json pins their checksums, so the build cannot fetch them itself.
  dxvkSource = fetchurl {
    url = "https://github.com/doitsujin/dxvk/archive/refs/tags/v3.2.tar.gz";
    hash = "sha256-AQFaIo7HPsTyfNxhSoQGVqotCeWfzsHNsrYkvOnkFWU=";
  };

  vkd3dProtonSource = fetchFromGitHub {
    owner = "HansKristian-Work";
    repo = "vkd3d-proton";
    rev = "4522cc1a8b1347f1ab1b0f7b14a23ed9444d95d1";
    fetchSubmodules = true;
    hash = "sha256-61stB+b8HS9X3ElpmUPW64ud7FtO8JXA4HliMcJKFj0=";
  };

  zlibSrc = fetchurl {
    url = "https://zlib.net/fossils/zlib-1.3.1.tar.gz";
    hash = "sha256-mpOyt9/ax3zrpaVYpYDnRmfdb+3kWFuR7vtg8Dty3yM=";
  };

  libjpegSrc = fetchurl {
    url = "https://www.ijg.org/files/jpegsrc.v10.tar.gz";
    hash = "sha256-i56qEyQmkOvQPhcoqx7fl6gaeO1ug2JNSTZV8xrJWrU=";
  };

  libtiffSrc = fetchurl {
    url = "https://download.osgeo.org/libtiff/tiff-4.7.1.tar.gz";
    hash = "sha256-9pjZTzED2oynQ42E4DRORT/gujt0huBMW/epo/q+m2k=";
  };

  libxml2Src = fetchurl {
    url = "https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.8.tar.xz";
    hash = "sha256-Q62HewGLxj3rJGjXH5UhnC+sGWh27zbRvuUdImFz7JM=";
  };

  wuffsSrc = fetchurl {
    url = "https://github.com/google/wuffs/archive/refs/tags/v0.4.0-alpha.12.tar.gz";
    hash = "sha256-DByEqpP8rtpSPtUXhIsVVecuZ5w3eAqqLbjX5bj/ePE=";
  };

  libxsltSrc = fetchurl {
    url = "https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.42.tar.xz";
    hash = "sha256-hcpiysDUH8d9P2Az2p32/XPSDqL8GLCjYJ/7QRDhuus=";
  };

  rootCerts = {
    MicrosoftRootAuthority = fetchurl {
      url = "http://www.microsoft.com/pki/certs/MicrosoftRootAuthority.crt";
      hash = "sha256-84QG5UDXqdkMtKlHkplkD/tt+eIk7MegHA2VWNja130=";
    };
    MicrosoftRootCert = fetchurl {
      url = "http://www.microsoft.com/pki/certs/MicrosoftRootCert.crt";
      hash = "sha256-iF3mTDQOPqcGWPAeEUX5V/zaJ6q+6hq5+qn9sBAtQHc=";
    };
    "MicRooCerAut_2010-06-23" = fetchurl {
      url = "http://www.microsoft.com/pki/certs/MicRooCerAut_2010-06-23.crt";
      hash = "sha256-31Rb+RmiQ5w2mDtUzfyQPfpPN9OZbY2EtMMe7G88Fj4=";
    };
    "MicRooCerAut2011_2011_03_22" = fetchurl {
      url = "http://www.microsoft.com/pki/certs/MicRooCerAut2011_2011_03_22.crt";
      hash = "sha256-hH32p4SXlD8n/HLrk/mmNzIKArVh0KkbCeh6eAftfGE=";
    };
    MicrosoftIdentityVerificationRootCA2020 = fetchurl {
      url = "http://www.microsoft.com/pkiops/certs/Microsoft%20Identity%20Verification%20Root%20Certificate%20Authority%202020.crt";
      hash = "sha256-U2fyDHreDivKeQkVBW0Ia3IMM8H6KiZhrPeH4ykuEnA=";
    };
  };

  mingw64 = pkgsCross.mingwW64.buildPackages;
  mingw32 = pkgsCross.mingw32.buildPackages;
in
stdenv.mkDerivation {
  pname = "raven";
  version = "0-unstable-2026-11-28";

  src = ravenSrc;

  patches = [
    ./skip-fixture-downloads.patch
    ./find-vulkan-registry.patch
  ];

  env.CARGO_NET_OFFLINE = "true";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    makeBinaryWrapper
    bison
    patch
    zstd
    wayland-scanner
    wine64Packages.minimal # widl
    mingw64.gcc
    mingw64.binutils
    mingw32.gcc
    mingw32.binutils
    # native/peparse and native/waits are built by CMake through cargo.
    cargo
    rustc
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
    pixman
    freetype
    libpng
    openssl
    vulkan-loader
    vulkan-headers
    libglvnd
    libGLU
    libxcb
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
  ];

  # Guest components and graphics are prepared before CMake configuration.
  preConfigure = ''
    export HOME=$TMPDIR
    components=$NIX_BUILD_TOP/raven-components
    mkdir -p "$components"/{controls64,controls32,installer64,installer32,rtl,roots,graphics}

    # cargo runs from CMake during the build; point it at the vendored crates.
    export CARGO_HOME=$TMPDIR/cargo-home
    mkdir -p "$CARGO_HOME"
    cat > "$CARGO_HOME/config.toml" <<EOF
    [source.crates-io]
    replace-with = "vendored-sources"
    [source.vendored-sources]
    directory = "${waitsCargoDeps}"
    EOF

    # Microsoft code-signing roots (offline; provision-roots.py would download them).
    cp -v ${rootCerts.MicrosoftRootAuthority} "$components/roots/MicrosoftRootAuthority.crt"
    cp -v ${rootCerts.MicrosoftRootCert} "$components/roots/MicrosoftRootCert.crt"
    cp -v ${rootCerts."MicRooCerAut_2010-06-23"} "$components/roots/MicRooCerAut_2010-06-23.crt"
    cp -v ${rootCerts."MicRooCerAut2011_2011_03_22"} "$components/roots/MicRooCerAut2011_2011_03_22.crt"
    cp -v ${rootCerts.MicrosoftIdentityVerificationRootCA2020} \
      "$components/roots/MicrosoftIdentityVerificationRootCA2020.crt"
    python3 scripts/provision-roots.py --output "$components/roots"

    # DXVK / vkd3d-proton Windows DLLs, plus the source archives backends.json
    # pins for their provenance records.
    cp -v ${dxvk} "$components/graphics/dxvk-3.2.tar.gz"
    cp -v ${vkd3dProton} "$components/graphics/vkd3d-proton-3.1.tar.zst"
    cp -v ${dxvkSource} "$components/graphics/dxvk-3.2-source.tar.gz"
    mkdir -p "$TMPDIR/vkd3d-proton-source/vkd3d-proton-3.1"
    cp -r ${vkd3dProtonSource}/. "$TMPDIR/vkd3d-proton-source/vkd3d-proton-3.1/"
    chmod -R u+w "$TMPDIR/vkd3d-proton-source"
    tar --sort=name --mtime=@0 --owner=0 --group=0 --numeric-owner -czf \
      "$components/graphics/vkd3d-proton-3.1-source.tar.gz" \
      -C "$TMPDIR/vkd3d-proton-source" .
    python3 scripts/provision-graphics.py --destination "$components/graphics"

    # Guest controls (comctl32, shell dialogs, …)
    python3 scripts/provision-controls.py --output "$components/controls64" --arch x64
    python3 scripts/provision-controls.py --output "$components/controls32" --arch x86

    # Guest RTL
    python3 scripts/provision-rtl.py --output "$components/rtl"

    # Installer / WinSxS / MSI stack and its pinned C library sources
    cp -v ${zlibSrc} "$components/installer64/zlib-1.3.1-source.tar.gz"
    cp -v ${libjpegSrc} "$components/installer64/libjpeg-10-source.tar.gz"
    cp -v ${libtiffSrc} "$components/installer64/libtiff-4.7.1-source.tar.gz"
    cp -v ${libxml2Src} "$components/installer64/libxml2-2.12.8-source.tar.xz"
    cp -v ${libxsltSrc} "$components/installer64/libxslt-1.1.42-source.tar.xz"
    cp -v ${wuffsSrc} "$components/installer64/wuffs-0.4.0-alpha.12-source.tar.gz"
    python3 scripts/provision-installer.py --output "$components/installer64" --arch x64

    cp -v ${zlibSrc} "$components/installer32/zlib-1.3.1-source.tar.gz"
    cp -v ${libjpegSrc} "$components/installer32/libjpeg-10-source.tar.gz"
    cp -v ${libtiffSrc} "$components/installer32/libtiff-4.7.1-source.tar.gz"
    cp -v ${libxml2Src} "$components/installer32/libxml2-2.12.8-source.tar.xz"
    cp -v ${libxsltSrc} "$components/installer32/libxslt-1.1.42-source.tar.xz"
    cp -v ${wuffsSrc} "$components/installer32/wuffs-0.4.0-alpha.12-source.tar.gz"
    python3 scripts/provision-installer.py --output "$components/installer32" --arch x86

    cmakeFlagsArray+=(
      -DRAVEN_CONTROLS_COMPONENT_DIR="$components/controls64"
      -DRAVEN_CONTROLS32_COMPONENT_DIR="$components/controls32"
      -DRAVEN_INSTALLER_COMPONENT_DIR="$components/installer64"
      -DRAVEN_INSTALLER32_COMPONENT_DIR="$components/installer32"
      -DRAVEN_RTL_COMPONENT_PATH="$components/rtl/raven-rtl.dll"
      -DRAVEN_ROOT_CERTIFICATE_DIRECTORY="$components/roots"
      -DRAVEN_DXVK_PE64_DIR="$components/graphics/dxvk/pe64"
      -DRAVEN_DXVK_PE32_DIR="$components/graphics/dxvk/pe32"
      -DRAVEN_VKD3D_PE64_DIR="$components/graphics/vkd3d-proton/pe64"
    )
  '';

  # Build the runtime plus ALL targets that stage guest components beside it.
  # (installer_components_* and root_certificates are not deps of `raven`.)
  buildPhase = ''
    runHook preBuild
    cmake --build . -j"$NIX_BUILD_CORES" --target \
      raven \
      raven-bootstrap \
      installer_components_64 \
      installer_components_32 \
      root_certificates \
      windows_winmd \
      intl_nls
    runHook postBuild
  '';

  # Upstream has no install() rules.
  dontUseCmakeInstall = true;

  installPhase = ''
    runHook preInstall

    runtime=$out/libexec/raven
    mkdir -p "$runtime"/{x86,roots,WinMetadata} "$out/bin" "$out/share/raven/graphics"

    install -Dm755 native/raven "$runtime/raven"
    install -Dm755 native/raven-bootstrap "$runtime/raven-bootstrap"

    shopt -s nullglob
    for f in native/*.{dll,exe,ocx,com,nls}; do
      cp -a "$f" "$runtime/"
    done
    if [ -d native/x86 ]; then
      for f in native/x86/*.{dll,exe,ocx,com,nls}; do
        cp -a "$f" "$runtime/x86/"
      done
    fi
    if [ -d native/roots ]; then
      cp -a native/roots/. "$runtime/roots/"
    fi
    # Fallback: stage roots directly from the provisioned tree if CMake skipped them.
    if [ -z "$(ls -A "$runtime/roots" 2>/dev/null)" ]; then
      cp -a "$NIX_BUILD_TOP/raven-components/roots/." "$runtime/roots/"
    fi
    if [ -d native/WinMetadata ]; then
      cp -a native/WinMetadata/. "$runtime/WinMetadata/"
    fi
    shopt -u nullglob

    cp -a "$NIX_BUILD_TOP/raven-components/graphics/dxvk" "$out/share/raven/graphics/"
    cp -a "$NIX_BUILD_TOP/raven-components/graphics/vkd3d-proton" "$out/share/raven/graphics/"

    # Binary wrapper so /proc/self/exe resolves to the real runtime binary
    # (guest DLLs and roots are loaded from that directory).
    makeBinaryWrapper "$runtime/raven" "$out/bin/raven" \
      --set-default RAVEN_D3D_DIRECTORY \
        "$out/share/raven/graphics/dxvk/pe64:$out/share/raven/graphics/vkd3d-proton/pe64"

    runHook postInstall
  '';

  doCheck = false;

  passthru.updateScript = writeShellApplication {
    name = "update-raven";
    runtimeInputs = [
      git
      gnused
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="raven"
      ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [ "--version=branch" ];
        })
      } "$@"

      # Upstream's only tag is the rolling `nightly` tag, which nix-update turns
      # into `nightly-unstable-<date>`. There are no releases, so keep this
      # repo's `0-unstable-<date>` convention instead.
      repo_root="$(git rev-parse --show-toplevel)"
      sed -i -E 's/^(\s*version = )"nightly-unstable-/\1"0-unstable-/' \
        "$repo_root/by-name/ra/raven/package.nix"
    '';
  };

  meta = {
    description = "Run Windows applications on Linux with their own installers";
    longDescription = ''
      Raven runs Windows programs on x86_64 Linux inside a supervised guest
      process, implementing Windows kernel services, the registry, files, and
      a Wayland/X11 desktop. Direct3D goes through DXVK and vkd3d-proton.

      Skia-based guest text rendering is not enabled in this package yet;
      console and many GUI programs still run. Give each application its own
      prefix via RAVEN_PREFIX.
    '';
    homepage = "https://useraven.org";
    changelog = "https://github.com/mirkobrombin/raven/commits/main";
    license = with lib.licenses; [
      gpl3Plus
      mit
    ];
    maintainers = [ ];
    mainProgram = "raven";
    platforms = [ "x86_64-linux" ];
  };
}
