{
  clangStdenv,
  lib,
  runCommandWith,
  writeShellScript,
  writeShellApplication,
  nix-update-script,
  fetchFromGitHub,
  testers,

  freetype,
  libjpeg,
  libpng,
  libtiff,
  giflib,
  libX11,
  libXext,
  libXrandr,
  libXcursor,
  libxkbfile,
  cairo,
  libglvnd,
  fontconfig,
  dbus,
  libGLU,
  fuse3,
  ffmpeg,
  pulseaudio,
  systemdMinimal,

  coreutils,
  makeWrapper,
  python2,
  python3,
  cmake,
  ninja,
  pkg-config,
  bison,
  flex,

  libbsd,
  libxml2,
  openssl,

  xdg-user-dirs,

  addDriverRunpath,

  # Whether to pre-compile Python 2 bytecode for performance.
  compilePy2Bytecode ? false,
}:
let
  stdenv = clangStdenv;

  # The build system invokes clang to compile Darwin executables.
  # In this case, our cc-wrapper must not be used.
  ccWrapperBypass =
    runCommandWith
      {
        inherit stdenv;
        name = "cc-wrapper-bypass";
        runLocal = false;
        derivationArgs = {
          template = writeShellScript "template" ''
            for (( i=1; i<=$#; i++)); do
              j=$((i+1))
              if [[ "''${!i}" == "-target" && "''${!j}" == *"darwin"* ]]; then
                # their flags must take precedence
                exec @unwrapped@ "$@" $NIX_CFLAGS_COMPILE
              fi
            done
            exec @wrapped@ "$@"
          '';
        };
      }
      ''
        unwrapped_bin=${stdenv.cc.cc}/bin
        wrapped_bin=${stdenv.cc}/bin

        mkdir -p $out/bin

        unwrapped=$unwrapped_bin/$CC wrapped=$wrapped_bin/$CC \
          substituteAll $template $out/bin/$CC
        unwrapped=$unwrapped_bin/$CXX wrapped=$wrapped_bin/$CXX \
          substituteAll $template $out/bin/$CXX

        chmod +x $out/bin/$CC $out/bin/$CXX
      '';

  wrappedLibs = [
    # To find all of them: rg -w wrap_elf

    # src/native/CMakeLists.txt
    freetype
    libjpeg
    libpng
    libtiff
    giflib
    libX11
    libXext
    libXrandr
    libXcursor
    libxkbfile
    cairo
    libglvnd
    fontconfig
    dbus
    libGLU

    # src/external/darling-dmg/CMakeLists.txt
    fuse3

    # src/CoreAudio/CMakeLists.txt
    ffmpeg
    pulseaudio
  ];

  # The pinned darlingserver predates the DisablePointerAuthentication system
  # setting that prefsd and mldr read.
  darlingserverSrc = fetchFromGitHub {
    owner = "darlinghq";
    repo = "darlingserver";
    rev = "1f39685b1c65b87978de3ed0d0d27b2d632d1a4e";
    hash = "sha256-jNmbu+HC+wIvpVJLjN+odE39rwwhQwLALHiuyWZ78ww=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "darling";
  version = "0.1.20260608-unstable-2026-11-11";

  src = fetchFromGitHub {
    owner = "darlinghq";
    repo = "darling";
    rev = "f7fae379960fed66e33bab4a96b674652d8f4400";
    fetchSubmodules = true;
    hash = "sha256-syiyHD1V839Wpo7ttxt3PEL72CeEPxkuEZZ1cHHtl1o=";
    # Remove 500MB of dependency test files to get under Hydra output limit
    postFetch = ''
      rm -r $out/src/external/openjdk/test
      rm -r $out/src/external/libmalloc/tests
      rm -r $out/src/external/libarchive/libarchive/tar/test
    '';
  };

  outputs = [
    "out"
    "sdk"
  ];

  patches = [
    ./fuse3.patch
    # Keep XNU headers from shadowing glibc headers in host unit tests.
    ./host-test-headers.patch
  ];

  postPatch = ''
            # The pinned darlingserver predates the DisablePointerAuthentication
            # system setting that prefsd and mldr read, so take the tree that adds
            # it. Swapping it here loses the tests/CMakeLists.txt hunk of
            # ./host-test-headers.patch, which is reapplied in the submodule's own
            # layout, and the swap comes before patchShebangs so its scripts are
            # rewritten too.
            chmod -R u+w src/external/darlingserver
            rm -rf src/external/darlingserver
            cp -a ${darlingserverSrc} src/external/darlingserver
            chmod -R u+w src/external/darlingserver
            patch -p4 -N -d src/external/darlingserver < ${./host-test-headers.patch}

            # We have to be careful - Patching everything indiscriminately
            # would affect Darwin scripts as well
            chmod +x src/external/bootstrap_cmds/migcom.tproj/mig.sh
            patchShebangs \
              src/external/bootstrap_cmds/migcom.tproj/mig.sh \
              src/external/darlingserver/scripts \
              src/external/darlingserver/tests/host \
              src/external/openssl_certificates/scripts

            substituteInPlace src/startup/CMakeLists.txt --replace-warn SETUID ""
            substituteInPlace src/external/basic_cmds/CMakeLists.txt --replace-warn SETGID ""

            # Nix has no /bin/mkdir or /bin/chmod, and bare commands would resolve to the Darling
            # targets, which makes the MIG custom command a dependency cycle.
            substituteInPlace cmake/mig.cmake --replace-warn /bin/mkdir ${coreutils}/bin/mkdir
            substituteInPlace src/external/bootstrap_cmds/CMakeLists.txt --replace-warn /bin/chmod ${coreutils}/bin/chmod

            # Upstream PR #1842 requires libsystem_kernel to publish DARLING_OS_* properties,
            # which is pending xnu submodule update (darling-xnu#46).
            substituteInPlace src/frameworks/CoreServices/CMakeLists.txt \
              --replace-warn 'if (NOT DARLING_OS_PRODUCT_VERSION OR NOT DARLING_OS_BUILD_VERSION)' \
                             'if (NOT DARLING_OS_PRODUCT_VERSION)
          set(DARLING_OS_PRODUCT_VERSION "26.4")
        endif()
        if (NOT DARLING_OS_BUILD_VERSION)
          set(DARLING_OS_BUILD_VERSION "25E246")
        endif()
        if (FALSE)'

            # This revision merged several stub-framework pulls that each added the
            # same add_subdirectory(), and CMake rejects the repeat as a duplicate
            # binary directory. Keep the first occurrence.
            awk '{ key = $0; gsub(/[[:space:]]+/, "", key);
                   if (key ~ /^add_subdirectory[(]/ && seen[key]++) next } { print }' \
              src/private-frameworks/CMakeLists.txt > private-frameworks.CMakeLists.txt.orig
            mv private-frameworks.CMakeLists.txt.orig src/private-frameworks/CMakeLists.txt

            # The pinned cocotron writes the image resolution with
            # kCGImageDestinationDPI, which ImageIO no longer exports. Upstream
            # cocotron fixed this in 433ed8cb5f by passing Onyx2D's own key.
            substituteInPlace src/external/cocotron/AppKit/NSBitmapImageRep.m \
              --replace-warn '#import <AppKit/NSView.h>' '#import <AppKit/NSView.h>
    #import <Onyx2D/O2ImageDestination.h>' \
              --replace-warn kCGImageDestinationDPI kO2ImageDestinationDPI

            # Top-level enable_testing() creates a phony `test` target in every subdirectory,
            # which conflicts with shell_cmds's `test` binary (output of test-bin).
            substituteInPlace CMakeLists.txt \
              --replace-warn "enable_testing()" ""

            # In sandbox package builds there are no running containers and no sudo.
            echo "exit 0" > tools/shutdown-user.sh
  '';

  nativeBuildInputs = [
    bison
    ccWrapperBypass
    cmake
    coreutils
    flex
    makeWrapper
    ninja
    pkg-config
    python3
  ]
  ++ lib.optional compilePy2Bytecode python2;
  buildInputs = wrappedLibs ++ [
    libbsd
    libxml2
    openssl
    stdenv.cc.libc.linuxHeaders
    systemdMinimal
  ];

  # Breaks valid paths like
  # Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include
  dontFixCmake = true;

  # src/external/objc4 forces OBJC_IS_DEBUG_BUILD=1, which conflicts with NDEBUG
  # TODO: Fix in a better way
  cmakeBuildType = " ";

  cmakeFlags = [
    "-DTARGET_i386=OFF"
    "-DCOMPILE_PY2_BYTECODE=${if compilePy2Bytecode then "ON" else "OFF"}"
    "-DDARLINGSERVER_XDG_USER_DIR_CMD=${xdg-user-dirs}/bin/xdg-user-dir"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-macro-redefined -Wno-unused-command-line-argument";

  # Linux .so's are dlopen'd by wrapgen during the build
  env.LD_LIBRARY_PATH = lib.makeLibraryPath wrappedLibs;

  # Breaks shebangs of Darwin scripts
  dontPatchShebangs = true;
  dontCheckForBrokenSymlinks = true;

  postInstall = ''
    # Install the SDK as a separate output
    mkdir -p $sdk

    sdkDir=$(readlink -f ../Developer)

    while read -r path; do
      dst="$sdk/Developer/''${path#$sdkDir}"

      if [[ -L "$path" ]]; then
        target=$(readlink -m "$path")
        if [[ -e "$target" && "$target" == "$NIX_BUILD_TOP"* && "$target" != "$sdkDir"* ]]; then
          # dereference
          cp -r -L "$path" "$dst"
        elif [[ -e "$target" ]]; then
          # preserve symlink
          cp -d "$path" "$dst"
        else
          # ignore symlink
          >&2 echo "Ignoring symlink $path -> $target"
        fi
      elif [[ -f $path ]]; then
        cp "$path" "$dst"
      elif [[ -d $path ]]; then
        mkdir -p "$dst"
      fi
    done < <(find $sdkDir)

    mkdir -p $sdk/bin
    cp src/external/cctools-port/cctools/ld64/src/*-ld $sdk/bin
    cp src/external/cctools-port/cctools/ar/*-{ar,ranlib} $sdk/bin
  '';

  postFixup = ''
    echo "Checking for references to $NIX_STORE in Darling root..."

    set +e
    grep -r --exclude=mldr --exclude=darpath "$NIX_STORE" $out/libexec/darling
    ret=$?
    set -e

    if [[ $ret == 0 ]]; then
      echo "Found references to $NIX_STORE in Darling root (see above)"
      exit 1
    fi

    patchelf --add-rpath "${lib.makeLibraryPath wrappedLibs}:${addDriverRunpath.driverLink}/lib" \
      $out/libexec/darling/usr/libexec/darling/mldr
  '';

  passthru = {
    tests.nixos = testers.nixosTest (import ./test.nix { darling = finalAttrs.finalPackage; });
    updateScript = writeShellApplication {
      name = "update-darling";
      text = ''
        export UPDATE_NIX_ATTR_PATH="darling"

        nix-update() {
          ${
            lib.escapeShellArgs (nix-update-script {
              extraArgs = [ "--version=branch" ];
            })
          } "$@"
        }

        # nix-update writes the new revision and version before it fetches the
        # source for its hash, and that fetch pulls in every submodule and takes
        # a long time. If it is interrupted, the revision has moved but the hash
        # is stale, and later runs report "Not updating version" and leave the
        # mismatch in place. Recompute the hash for the pinned revision even
        # when its version has not changed. Building src with the existing hash
        # can reuse an older fixed-output result without fetching this revision.
        update_hash() {
          ${
            lib.escapeShellArgs (nix-update-script {
              extraArgs = [ "--version=skip" ];
            })
          } "$@"
        }

        if ! nix-update "$@"; then
          echo "nix-update failed; updating the hash for the pinned revision" >&2
          update_hash || true
          exit 1
        fi

        update_hash "$@"
      '';
    };
  };

  meta = with lib; {
    description = "Open-source Darwin/macOS emulation layer for Linux";
    homepage = "https://www.darlinghq.org";
    changelog = "https://github.com/darlinghq/darling/releases";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ zhaofengli ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "darling";
  };
})
