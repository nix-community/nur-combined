# SPDX-FileCopyrightText: Copyright 2026 Eglantine Community

# SPDX-FileCopyrightText: Copyright 2026 Eglantine Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  pkgs,
  buildEdenEmulator,
  llvmPackages_23,
  src,
  version,
  pgo ? false,
  # CPU tuning, off by default, only here for tinkerers
  march ? null,
  # mark the binary as a Nix-specific build. On by default: the dependency set
  # is not identical to the release builds. Several dependencies come from
  # nixpkgs rather than cpmfile.json (and at nixpkgs' version where the
  # manifest pin could not be carried over), so the title bar says where the
  # binary came from instead of implying it is the same build as the tarball.
  nixBuildIdentity ? true,
}:

let
  # ccache keys on the compiler command line, so the profile path inside it has
  # to be the same string on every commit. ${src} is a hash of the whole tree
  # and changes with every commit, which is what put the PGO variants at 0 hits
  # out of 3678 while the plain variant beside them hit 45%. builtins.path
  # hashes the file it is handed, so this path moves only when the profile
  # itself moves -- the property upstream gets for free by passing
  # -fprofile-use=$PWD/eglantine.profdata.
  #
  # Both are lazy and only forced under pgo, so a tree without a profile still
  # evaluates; a fork that has none is unaffected unless it asks for PGO.
  srcPath = if builtins.isPath src then src else /. + src;
  pgoProfile = builtins.path {
    path = srcPath + "/eglantine.profdata";
    name = "eglantine.profdata";
  };

  profile = lib.optionalString pgo (toString [
    "-fprofile-use=${pgoProfile}"
    "-Wno-backend-plugin"
    "-Wno-profile-instr-unprofiled"
    "-Wno-profile-instr-out-of-date"
  ]);

  archFlags = lib.optionalString (march != null) "-march=${march} -mtune=${march}";

  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  pgoBintools = lib.optional (pgo && !isDarwin) llvmPackages_23.bintools;
  pgoLinkerFlags = lib.optionals (pgo && !isDarwin) [
    "-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld"
    "-DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=lld"
    "-DCMAKE_MODULE_LINKER_FLAGS=-fuse-ld=lld"
  ];

  # Eglantine's dependency list. Written out rather than inherited from
  # pkgs.eden: that made this package's dependencies another emulator's
  # decision (Eden links SDL2 where this tree is SDL3-only, fmt_11 where
  # cpmfile.json asks for 12.1.0), made it fail outright if nixpkgs ever
  # renamed `eden`, and cannot be submitted to nixpkgs, where a derivation
  # cannot inherit from a sibling one.
  #
  # Policy: nixpkgs first. cpmfile.json stays the pin, but a dependency that
  # nixpkgs can serve is taken from nixpkgs instead of being compiled from
  # source here -- it arrives from the binary cache and its build recipe is
  # maintained upstream. Only what nixpkgs cannot serve is built from the
  # manifest, which is what the -D<package>_FORCE_SYSTEM flags below select.
  #
  # Listed here because CPM cannot serve them:
  #   ffmpeg-headless  deliberately the system build, see the FFmpeg note below
  #   openssl          upstream's Linux build links the system OpenSSL too
  #   gamemode         Linux only, loaded by the running process rather than
  #                    linked; upstream installs the distro's dev package
  #   qt6.qtbase       Core, Gui, Widgets and Concurrent all live here
  #   qt6.qtcharts     listed in YUZU_QT_COMPONENTS, so required unconditionally
  #   qt6.qtwayland    the wayland platform plugin the wrapper hook needs
  #
  # Removed from the inherited Eden list because nothing here uses them:
  #   SDL2, stb (vendored in externals/stb, which defines the target),
  #   unordered_dense (no reference anywhere in the tree), qt6.qtmultimedia and
  #   qt6.qtwebengine (both options default OFF and are never set here)
  nativeDeps = with pkgs; [
    cmake
    ninja
    glslang
    pkg-config
    python3
    qt6.qttools
    qt6.wrapQtAppsHook
    wrapGAppsHook3
  ];

  # nixpkgs' SDL3, pinned to the version cpmfile.json asks for. Using the
  # nixpkgs recipe keeps SDL3's own build dependencies out of this expression:
  # while it was compiled from source here, they all had to be listed by hand
  # and every SDL3 bump could add another required library -- the first
  # stripped-down build died exactly that way, on XSCRNSAVER.
  sdl3Pinned = pkgs.sdl3.overrideAttrs (_: {
    version = "3.4.8";
    src = pkgs.fetchFromGitHub {
      owner = "libsdl-org";
      repo = "SDL";
      rev = "release-3.4.8";
      hash = "sha256-uBGyGxrUVx642Ku8qhR2sTy2JagcSioIhh/5RsXVAIM=";
    };
  });

  # A nixpkgs package moved onto the version cpmfile.json pins. `hash` is the
  # unpacked-tree hash of the GitHub archive (nix store prefetch-file --unpack),
  # which is what fetchFromGitHub expects for a tag or commit.
  #
  # patches = [ ] because nixpkgs' patch set is written for the version nixpkgs
  # ships, not for the one the manifest pins -- fmt's 12.2.0 fix fails to apply
  # to 12.1.0 and aborts the unpack phase. A package that still needs a patch at
  # the pinned version has to pass it explicitly.
  pinTo =
    {
      pkg,
      owner,
      repo,
      version,
      rev,
      hash,
      patches ? [ ],
    }:
    pkg.overrideAttrs (_: {
      inherit version patches;
      # Their test suite is not ours to run, and nixpkgs' one is written for the
      # version nixpkgs ships: zstd's wants a static library we never ask for.
      doCheck = false;
      src = pkgs.fetchFromGitHub {
        inherit
          owner
          repo
          rev
          hash
          ;
      };
    });

  # nixpkgs marks these Linux-only (meta.platforms), so they cannot live in
  # pinnedDeps: on darwin they have to come from the manifest instead.
  siritPinned = pinTo {
    pkg = pkgs.sirit;
    owner = "eden-emulator";
    repo = "sirit";
    version = "v1.0.5";
    rev = "v1.0.5";
    hash = "sha256-T4f1C33rh8KEXPyxPiIbdDUQLGT3ufTIt4XmgSsLRpA=";
  };

  gamemodePinned = pinTo {
    pkg = pkgs.gamemode;
    owner = "FeralInteractive";
    repo = "gamemode";
    version = "1.8.2-unstable-2026-11-15";
    rev = "ce6fe122f3";
    hash = "sha256-RMi4PBKqx1kdthKPs8x7GZyvIapo8PXDeMoT4QCxiws=";
  };

  pinnedDeps = [
    (pinTo {
      pkg = pkgs.fmt;
      owner = "fmtlib";
      repo = "fmt";
      version = "12.1.0";
      rev = "12.1.0";
      hash = "sha256-ZmI1Dv0ZabPlxa02OpERI47jp7zFfjpeWCy1WyuPYZ0=";
    })
    (pinTo {
      pkg = pkgs.simpleini;
      owner = "brofield";
      repo = "simpleini";
      version = "v4.25";
      rev = "v4.25";
      hash = "sha256-1JTVjMfEuWqlyYAm4Er6HPjrP2Tnt0ntai8oVvIEOu0=";
    })
    (pinTo {
      pkg = pkgs.xbyak;
      owner = "herumi";
      repo = "xbyak";
      version = "v7.40.1";
      rev = "v7.40.1";
      hash = "sha256-PdeN2ArmqznAThe1KE5d9v6CglA8e81Rm8hH9lCZVKY=";
    })
    (pinTo {
      pkg = pkgs.lz4;
      owner = "lz4";
      repo = "lz4";
      version = "1.10.0-unstable-2026-11-15";
      rev = "ebb370ca83";
      hash = "sha256-/dG1n59SKBaEBg72pAWltAtVmJ2cXxlFFhP+klrkTos=";
    })
    (pinTo {
      pkg = pkgs.cubeb;
      owner = "mozilla";
      repo = "cubeb";
      version = "0-unstable-2026-11-15";
      rev = "fa02160712";
      hash = "sha256-6PUHUPybe3g5nexunAHsHLThFdvpnv+avks+C0oYih0=";
    })
    (pinTo {
      pkg = pkgs.vulkan-headers;
      owner = "KhronosGroup";
      repo = "Vulkan-Headers";
      version = "v1.4.345";
      rev = "v1.4.345";
      hash = "sha256-bZKNFiZMVYDxa6RKb1c/GxIR+eEFQAyYNaEptzQW5TE=";
    })
    (pinTo {
      pkg = pkgs.vulkan-utility-libraries;
      owner = "KhronosGroup";
      repo = "Vulkan-Utility-Libraries";
      version = "v1.4.345";
      rev = "v1.4.345";
      hash = "sha256-4XsQN94JsQXFGwJKp3W2gdTCCxUZrpCKiRVXzxL+Qs0=";
    })
  ];

  deps =
    with pkgs;
    [
      ffmpeg-headless
      openssl
      qt6.qtbase
      qt6.qtcharts
      sdl3Pinned
    ]
    ++ pinnedDeps
    ++ [

      # nixpkgs ships these at the exact version cpmfile.json pins, so they
      # come from the binary cache instead of being compiled from the manifest.
      enet
      nlohmann_json
      oaknut
      zlib

      # libusb's manifest entry carries one patch, 0001-netbsd-gettime.patch,
      # which does not apply to anything we build. Left to CPM it compiles from
      # source and insists on autoconf.
      libusb1
    ]
    ++ lib.optionals (!isDarwin) [
      gamemodePinned
      siritPinned
      qt6.qtwayland
    ];
in
buildEdenEmulator (
  {
    inherit src version;

    pname = "eglantine";

    nativeBuildInputs = nativeDeps;
    buildInputs = deps;

    stdenv = if pgo then llvmPackages_23.stdenv else pkgs.stdenv;

    extraNativeBuildInputs = pgoBintools;

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DBUILD_TESTING=OFF"
      "-DYUZU_ROOM=OFF"

      # NIGHTLY_BUILD is not a flag here: CMakeLists.txt turns it on when a
      # GIT-NIGHTLY file sits in the source root, the same way GIT-RELEASE
      # already decides release-ness. CI drops that file in before building.

      # Take these from nixpkgs rather than compiling them from the manifest.
      # CPMUtil checks <package>_FORCE_SYSTEM before the global option; the name
      # is the manifest's `package` field, or the entry key when absent. With
      # force_system set, a find_package miss is a FATAL_ERROR naming the
      # package, and a hit logs "Using system package <name>@<version>".
      "-DSDL3_FORCE_SYSTEM=ON"
      "-Denet_FORCE_SYSTEM=ON"
      "-Dnlohmann_json_FORCE_SYSTEM=ON"
      "-Doaknut_FORCE_SYSTEM=ON"
      "-Dlibusb_FORCE_SYSTEM=ON"
      "-Dfmt_FORCE_SYSTEM=ON"
      "-DSimpleIni_FORCE_SYSTEM=ON"
      "-Dxbyak_FORCE_SYSTEM=ON"
      "-Dlz4_FORCE_SYSTEM=ON"
      "-Dcubeb_FORCE_SYSTEM=ON"
      "-DVulkanHeaders_FORCE_SYSTEM=ON"
      "-DVulkanUtilityLibraries_FORCE_SYSTEM=ON"
      "-DZLIB_FORCE_SYSTEM=ON"

      # Matching upstream's build-linux.yml, which has always passed this for
      # the Linux release. discord-rpc comes from cpmfile.json like everything
      # else, so this costs a link step, not a new input.
      "-DUSE_DISCORD_PRESENCE=ON"

      # Nix deviations:
      # 1. QT6 is found through the setup hook,
      #    so no prefix path is needed
      # 2. NIGHTLY_BUILD is a function argument,
      #    not a workflow input (checking env vars is impure)
      # 3. SDL3 is built from source for Nix's reproducibility reasons
      #    (not downloaded, but Cachix is integrated in CI)
      # 4. Nixpkgs currently ships GCC 16, which is stricter than
      #    Ubuntu's GCC 13, so -Werror is disabled to avoid build failures
      # 5. FFmpeg is the nixpkgs build, not upstream's bundled static one.
      #    Upstream bundles 9.0.2 because its tar.gz linked Ubuntu's
      #    libavcodec.so.60 (absent on users' machines), needed libva 2.20
      #    instead of 2.21+, and wanted dav1d on aarch64. None of that
      #    transfers: nixpkgs' ffmpeg-headless IS ffmpeg_9-headless, 9.0.2
      #    with dav1d, and the store path is baked into the binary. Do not set
      #    YUZU_USE_BUNDLED_FFMPEG=ON: it selects ffmpeg-ci-av1-linux, a `ci`
      #    entry with no hash that this builder cannot fetch, so configure
      #    would try to download in the sandbox.
      #    (Same trap for -DYUZU_USE_BUNDLED_SDL3=ON -> sdl3-ci.)
      #    Watch it if nixpkgs moves its unversioned ffmpeg default.

      "-DENABLE_WERROR=OFF"
      # The plain legs turn this on for release and daily builds; keep it off
      # here. A package manager owns updates, and an in-app download would put a
      # tarball or AppImage inside a store-managed tree that the flake input
      # knows nothing about. Pinned explicitly rather than left to the default,
      # so a default flip upstream cannot silently change this package.
      "-DENABLE_UPDATE_CHECKER=OFF"
    ]
    # sirit and gamemode are Linux-only in nixpkgs, so both their packages
    # and the instruction to look for them are conditional.
    ++ lib.optionals (!isDarwin) [
      "-Dsirit_FORCE_SYSTEM=ON"
      "-Dgamemode_FORCE_SYSTEM=ON"
    ]
    ++ pgoLinkerFlags
    ++ lib.optionals pgo [
      "-DCMAKE_C_FLAGS=${profile} ${archFlags}"
      "-DCMAKE_CXX_FLAGS=${profile} ${archFlags}"
    ]
    ++ lib.optionals (!pgo && march != null) [
      "-DCMAKE_C_FLAGS=${archFlags}"
      "-DCMAKE_CXX_FLAGS=${archFlags}"
    ];

    # opt-in build-identity, see above
    env = lib.optionalAttrs nixBuildIdentity {
      # The identity in the title bar and the About dialog comes from GIT-DISPLAY
      # (branch, commit date, sha, PGO), so the only thing left to say is which
      # packaging layer produced this binary.
      EGLANTINE_FLAVOUR = "nix";
    };

    meta = {
      description = "Experimental Nintendo Switch 2 emulator";
      homepage = "https://github.com/Eglantine-Community/Eglantine";
      mainProgram = "eglantine";
      license = lib.licenses.gpl3Plus;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
  }
  // lib.optionalAttrs isDarwin {

    # dynarmic dependencies on darwin
    extraNativeBuildInputs = pgoBintools ++ [
      pkgs.darwin.bootstrap_cmds # mig
      pkgs.darwin.DarwinTools # sw_ver
    ];

    # depending on llvmPackages.libcxx would put its libc++.dylib
    # on the link path as well, and -lc++ would then resolve to that
    # copy instead of the SDK's -- a second C++ runtime, kept apart on purpose
    # -> we only take what we need
    extraBuildInputs = [
      (pkgs.runCommandLocal "libcxx-experimental" { } ''
        mkdir -p $out/lib
        cp ${pkgs.llvmPackages.libcxx}/lib/libc++experimental.a $out/lib/
      '')
    ];

    # simple Nix-specific install rules
    postInstall = lib.optionalString isDarwin ''
      mkdir -p $out/Applications $out/bin
      cp -R "$(find . -maxdepth 3 -name 'eglantine.app' -type d | head -1)" $out/Applications/
      install -m755 "$(find . -maxdepth 3 -name 'eden-cli' -type f | head -1)" $out/bin/

      # The same path as on every other platform, so meta.mainProgram and the
      # flake's apps output need no macOS special case.
      ln -s ../Applications/eglantine.app/Contents/MacOS/eglantine $out/bin/eglantine
    '';
  }
)
