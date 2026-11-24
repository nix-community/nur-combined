{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchzip,
  applyPatches,
  runCommand,
  cmake,
  ninja,
  pkg-config,
  python3,
  clang,
  lld,
  patchelf,
  glslang,
  qt6,
  vulkan-headers,
  vulkan-loader,
  libGL,
  libglvnd,
  alsa-lib,
  libpulseaudio,
  pipewire,
  dbus,
  systemd,
  libX11,
  libXcursor,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXScrnSaver,
  libXtst,
  libxkbcommon,
  wayland,
  wayland-protocols,
  libdecor,
  autoPatchelfHook,
  writeShellScriptBin,
  writeShellApplication,
  nix,
  git,
  coreutils,
  moltenvk,
  ldid,
  apple-sdk_26,
}:

let
  # Upstream re-signs kyty_emulator with its JIT entitlements and lets
  # macdeployqt sign the Qt frameworks; both call Xcode's codesign, which is
  # not available in the build sandbox.  ldid writes the same ad-hoc
  # signatures and can embed the entitlements, so masquerade as codesign.
  codesignShim = writeShellScriptBin "codesign" ''
    target=
    entitlements=
    while [ $# -gt 0 ]; do
      case $1 in
        --entitlements)
          entitlements=$2
          shift
          ;;
        -*) ;;
        *) target=$1 ;;
      esac
      shift
    done

    # macdeployqt also signs the bundle directory itself, which ldid cannot do.
    [ -d "$target" ] && exit 0

    if [ -n "$entitlements" ]; then
      exec ${lib.getExe ldid} -S"$entitlements" "$target"
    else
      exec ${lib.getExe ldid} -S "$target"
    fi
  '';

  # Track upstream's dated release tags rather than a bare commit, so
  # `nix-update`/`check_updates.py` and humans see the same version.
  src = fetchFromGitHub {
    owner = "KytyPS5";
    repo = "KytyPS5";
    tag = "KytyPS5-2026-11-23-cc817b6";
    hash = "sha256-rGJAxJeMB8fI4Kerhn159oiFB9kLEJH50ypmwY69hs4=";
  };

  # nixpkgs 26.11 dropped x86_64-darwin, and KytyPS5's macOS build is x86-64
  # only (the guest and the JIT are x86-64; Apple Silicon runs the result under
  # Rosetta), so it is packaged from the last branch that still has that package
  # set.  The pin lives here, not as a flake input, so the flake needs nothing
  # beyond nixpkgs.  It is the revision of nixpkgs-26.05-darwin.
  nixpkgsDarwin = fetchzip {
    url = "https://github.com/NixOS/nixpkgs/archive/94d362415787ffff528f73820996aeedd97ff0dd.tar.gz";
    hash = "sha256-lsIUChCLfoCyf0VO6CzedtMZBV62+1W86nT3XGCIgiw=";
  };

  # Submodules of 3rdparty/, pinned by the superproject.
  libAtrac9 = fetchFromGitHub {
    owner = "shadps4-emu";
    repo = "ext-LibAtrac9";
    rev = "ec8899dadf393f655f2871a94e0fe4b3d6220c9a";
    hash = "sha256-Na1/LOCSJ+fc1Q+0wpuH0jI/AgaqUmVhpN+zGZJ+aA4=";
  };

  sdl3 = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL";
    rev = "fa2c02bb6e21974a89ea9824bc53c9932abe5f9c";
    hash = "sha256-zSwjDbPkYYjm0yA05bq/0Dq+RU154J/gYOw8a2YmerA=";
  };

  spirvHeaders = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Headers";
    rev = "01e0577914a75a2569c846778c2f93aa8e6feddd";
    hash = "sha256-gewCQvcVRw+qdWPWRlYUMTt/aXrZ7Lea058WyqL5c08=";
  };

  spirvTools = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Tools";
    rev = "7f2d9ee926f98fc77a3ed1e1e0f113b8c9c49458";
    hash = "sha256-NXxC5XLvEEIAlA0sym6l7vWj+g8pJ4trsJI3pmZwRxU=";
  };

  vulkanHeaders = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-Headers";
    rev = "2fa203425eb4af9dfc6b03f97ef72b0b5bcb8350";
    hash = "sha256-DIePLzDoImnaso0WYUv819wSDeA7Zy1I/tYAbsALXKg=";
  };

  vulkanMemoryAllocator = fetchFromGitHub {
    owner = "GPUOpen-LibrariesAndSDKs";
    repo = "VulkanMemoryAllocator";
    rev = "a1d434708c217b2a6c7b365f1fe41fa03a562e59";
    hash = "sha256-P8JM7sKQbspTMK4KINa/M52sVnVO4w7L+ZKRPKfVRGw=";
  };

  ffmpegCore = fetchFromGitHub {
    owner = "KytyPS5";
    repo = "ext-ffmpeg-core";
    rev = "9ac4cfd195f192ed8b08566f49c28dbb48d08341";
    hash = "sha256-Fj15Xz26Jiw9B/oD72do22TNdLz+jmy0ZTT8lkWgQDA=";
  };

  fmt = fetchFromGitHub {
    owner = "fmtlib";
    repo = "fmt";
    rev = "11ddbcb7898d2d3445d431a54814367b21dee6ad";
    hash = "sha256-tLAhxh2v8344kOGT6z54fSjmZN+sCTjtFhw1UOYSuyw=";
  };

  imgui = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    rev = "f1cc2ae15e53a861a874c3034aae6798fde194ab";
    hash = "sha256-IjW+qddzKu9jOj3QCGhkChVK2UOvwl493ffUIIn/ZVQ=";
  };

  magicEnum = fetchFromGitHub {
    owner = "Neargye";
    repo = "magic_enum";
    rev = "1384769c66bd16ec9bb1353f45fe8ec8ccc12dbd";
    hash = "sha256-P26B9vEdvqmy8RO22EGbpKbuQTgosLJbdCJ5efTYA4U=";
  };

  nlohmannJson = fetchFromGitHub {
    owner = "nlohmann";
    repo = "json";
    rev = "272411c5e6ea45919af7673524e74e60c62116df";
    hash = "sha256-2F4brsRWoR1OgxsveOzz4cRmDL/Sv/u61Ze8DGhC6CU=";
  };

  spdlog = fetchFromGitHub {
    owner = "gabime";
    repo = "spdlog";
    rev = "8671ca4d492c8ee1cdfd3dd88afb9f88dd268178";
    hash = "sha256-w9wU41dhI3jU6ItzUGQNv8SR2c0mbIobdrl3LcqcN7U=";
  };

  tracy = fetchFromGitHub {
    owner = "wolfpld";
    repo = "tracy";
    rev = "30997d5ca6bb632cc10807a1da8a6d3de0aeeb3c";
    hash = "sha256-vcLI9jb7eYcR162LgBQ2P4A0oiZuYRfYRQiDhlAk5TI=";
  };

  xxHash = fetchFromGitHub {
    owner = "Cyan4973";
    repo = "xxHash";
    rev = "e573d4d2aaeaba0f3e5a0a9a54144a1f2b4b56e7";
    hash = "sha256-orIpwgqFH6mIMCQOBhnk9dxK8K7n6P13Nq2W96SBb08=";
  };

  # Dependencies 3rdparty/CMakeLists.txt pulls in with FetchContent.
  opus = fetchFromGitHub {
    owner = "xiph";
    repo = "opus";
    rev = "ddbe48383984d56acd9e1ab6a090c54ca6b735a6";
    hash = "sha256-M1G7ypcfs7nJmXgkyoG96jT/CkgN5BOzy+DGO4LVCvA=";
  };

  openxr = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenXR-SDK";
    rev = "f2448a8797c85814aa892efc1ab8707900fbcc78";
    hash = "sha256-glcHMArDabXbrxO4CY2QeTJFTeUTQH4v1O03LuhML7E=";
  };

  xbyak = fetchFromGitHub {
    owner = "herumi";
    repo = "xbyak";
    rev = "44a72f369268f7d552650891b296693e91db86bb";
    hash = "sha256-S4arAwbhTGsUhDFfy5fTGyDvCm0/x/LKiiPTAuRM8Yk=";
  };

  zydisSrc = fetchFromGitHub {
    owner = "zyantific";
    repo = "zydis";
    rev = "120e0e705f8e3b507dc49377ac2879979f0d545c";
    hash = "sha256-5xpebm6cxOlElCKEasfMgyPB4UcbY3kgQvjcogRKR38=";
  };

  zycore = fetchFromGitHub {
    owner = "zyantific";
    repo = "zycore-c";
    rev = "38d4f0285e6157ee840ea82a9b90aba71c8a705d";
    hash = "sha256-cKH44gm4WqPIWkTL+WqmiEjHVloVht1a8AbYeixsyfk=";
  };

  zstd = fetchFromGitHub {
    owner = "facebook";
    repo = "zstd";
    rev = "f8745da6ff1ad1e7bab384bd1f9d742439278e99";
    hash = "sha256-tNFWIT9ydfozB8dWcmTMuZLCQmQudTFJIkSr0aG7S44=";
  };

  zarchive = applyPatches {
    src = fetchFromGitHub {
      owner = "Exzap";
      repo = "ZArchive";
      rev = "d2c717730092c7bf8cbb033b12fd4001b7c4d932";
      hash = "sha256-hX637O/mVLTzmG0a9swJu9w+3o26VHo+K/9RhMuf1lI=";
    };
    # The sources use CRLF, which the upstream patch does not match.
    prePatch = ''
      sed -i 's/\r$//' include/zarchive/zarchivecommon.h src/zarchivereader.cpp
    '';
    patches = [ "${src}/3rdparty/patches/zarchive-reader.patch" ];
  };

  # ext-ffmpeg-core ships prebuilt archives per OS/arch.  The macOS one is
  # x86-64 only, like the rest of the macOS build.
  ffmpegPrebuilt = fetchzip {
    url =
      if stdenv.hostPlatform.isDarwin then
        "https://github.com/KytyPS5/ext-ffmpeg-core/releases/download/9ac4cfd195f1/ffmpeg-macos-x64.zip"
      else
        "https://github.com/KytyPS5/ext-ffmpeg-core/releases/download/9ac4cfd195f1/ffmpeg-linux-x64.zip";
    hash =
      if stdenv.hostPlatform.isDarwin then
        "sha256-3LHWD3Df1TK8qGHhm/S1ZfSZBU1x5oLIdyhXngdifbs="
      else
        "sha256-MX8Rifr6CvFFkm0IAmJPNGzLb8FG5HJJUKO/l0zegko=";
    stripRoot = false;
  };

  # LibFont's fallback face. The build normally downloads these from
  # notofonts.github.io, which the sandbox cannot reach.
  notoSans = runCommand "kytyps5-noto-sans" { } ''
    mkdir -p $out
    cp ${
      fetchurl {
        url = "https://raw.githubusercontent.com/notofonts/notofonts.github.io/42af67ccd12bc0e31ed85384bf73e39248265374/fonts/LICENSE";
        hash = "sha256-8glbCL7QiyOm/iYRL81nmivuPwAu7wd+sF0hXtEFG9g=";
      }
    } $out/LICENSE
    cp ${
      fetchurl {
        url = "https://raw.githubusercontent.com/notofonts/notofonts.github.io/42af67ccd12bc0e31ed85384bf73e39248265374/fonts/NotoSans/hinted/ttf/NotoSans-Regular.ttf";
        hash = "sha256-R4xVjqcWAzzWDANDj2KN+nVpTc9rX21QWi8F/StPOCM=";
      }
    } $out/NotoSans-Regular.ttf
    cp ${
      fetchurl {
        url = "https://raw.githubusercontent.com/notofonts/notofonts.github.io/42af67ccd12bc0e31ed85384bf73e39248265374/fonts/NotoSans/hinted/ttf/NotoSans-Bold.ttf";
        hash = "sha256-HfB1o4D8fLiYrPZMH3s7TdeA3jyqhgF4v5Kd41gXqRM=";
      }
    } $out/NotoSans-Bold.ttf
    cp ${
      fetchurl {
        url = "https://raw.githubusercontent.com/notofonts/notofonts.github.io/42af67ccd12bc0e31ed85384bf73e39248265374/fonts/NotoSans/hinted/ttf/NotoSans-Italic.ttf";
        hash = "sha256-Rn4/ie7KQQi7hxCiueDPIoGsVtWwYJIRqDd20FBe7LU=";
      }
    } $out/NotoSans-Italic.ttf
    cp ${
      fetchurl {
        url = "https://raw.githubusercontent.com/notofonts/notofonts.github.io/42af67ccd12bc0e31ed85384bf73e39248265374/fonts/NotoSans/hinted/ttf/NotoSans-BoldItalic.ttf";
        hash = "sha256-G2AqnWNTvkLJHfCXpIV7afomlvJnA9ejO1ShXYfCYiw=";
      }
    } $out/NotoSans-BoldItalic.ttf
  '';
in
if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.system != "x86_64-darwin" then
  # A native aarch64-darwin build would be an emulator upstream does not
  # support, so offer the x86_64-darwin derivation instead.
  (import nixpkgsDarwin {
    system = "x86_64-darwin";
    config.allowUnfree = true;
    config.android_sdk.accept_license = true;
  }).callPackage
    ./package.nix
    { }
else
  stdenv.mkDerivation {
    pname = "kytyps5";
    version = "0-unstable-2026-11-23";
    inherit src;

    patches = [ ./noto-fonts-local.patch ];

    # The macOS bundle gets its Qt runtime from macdeployqt, not a wrapper, and
    # stripping would invalidate the ad-hoc signatures added during the build.
    dontWrapQtApps = stdenv.hostPlatform.isDarwin;
    dontStrip = stdenv.hostPlatform.isDarwin;

    postPatch = ''
      cp -rT ${libAtrac9} 3rdparty/LibAtrac9
      cp -rT ${sdl3} 3rdparty/SDL3
      cp -rT ${spirvHeaders} 3rdparty/SPIRV-Headers
      cp -rT ${spirvTools} 3rdparty/SPIRV-Tools
      cp -rT ${vulkanHeaders} 3rdparty/Vulkan-Headers
      cp -rT ${vulkanMemoryAllocator} 3rdparty/VulkanMemoryAllocator
      cp -rT ${ffmpegCore} 3rdparty/ffmpeg-core
      cp -rT ${fmt} 3rdparty/fmt
      cp -rT ${imgui} 3rdparty/imgui
      cp -rT ${magicEnum} 3rdparty/magic_enum
      cp -rT ${nlohmannJson} 3rdparty/nlohmann_json
      cp -rT ${spdlog} 3rdparty/spdlog
      cp -rT ${tracy} 3rdparty/tracy
      cp -rT ${xxHash} 3rdparty/xxHash
      chmod -R u+w 3rdparty
    '';

    # The build fetches the Noto Sans faces itself; point it at the copies above.
    KYTY_NOTO_SANS_SRC = "${notoSans}";

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      python3
      clang
      glslang
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      lld
      patchelf
      autoPatchelfHook
      qt6.wrapQtAppsHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      ldid
      codesignShim
    ];

    buildInputs = [
      qt6.qtbase
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      vulkan-headers
      vulkan-loader
      libGL
      libglvnd
      alsa-lib
      libpulseaudio
      pipewire
      dbus
      systemd
      libX11
      libXcursor
      libXext
      libXfixes
      libXi
      libXrandr
      libXScrnSaver
      libXtst
      libxkbcommon
      wayland
      wayland-protocols
      libdecor
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # SDL loads MoltenVK rather than linking it; postFixup copies the dylib.
      moltenvk
      # The default x86_64-darwin SDK 14.4 predates <cstdlib>'s quick_exit,
      # which the emulator uses to skip destructors while the guest runs.
      apple-sdk_26
    ];

    # SDL's GLES and Steam controller probes leave these optional names behind;
    # neither ends up in the final binaries' NEEDED list.
    autoPatchelfIgnoreMissingDeps = lib.optionals stdenv.hostPlatform.isLinux [
      "libGLES_CM.so.1"
      "libsteam_api.so"
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DCMAKE_C_COMPILER=${clang}/bin/clang"
      "-DCMAKE_CXX_COMPILER=${clang}/bin/clang++"
      "-DBUILD_TESTING=OFF"
      "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
      "-DFETCHCONTENT_SOURCE_DIR_OPUS=${opus}"
      "-DFETCHCONTENT_SOURCE_DIR_OPENXR=${openxr}"
      "-DFETCHCONTENT_SOURCE_DIR_XBYAK=${xbyak}"
      "-DFETCHCONTENT_SOURCE_DIR_ZYDIS=${zydisSrc}"
      "-DZYAN_ZYCORE_PATH=${zycore}"
      "-DFETCHCONTENT_SOURCE_DIR_ZSTD=${zstd}"
      "-DFETCHCONTENT_SOURCE_DIR_ZARCHIVE_SOURCE=${zarchive}"
      "-DFFMPEG_PREBUILT_DIR=${ffmpegPrebuilt}"
    ]
    # The macOS build is x86-64 only: the guest and the JIT are x86-64, and
    # Apple Silicon runs the result under Rosetta.  Upstream keys the guest
    # address-space layout and the FFmpeg prebuilt on this setting.
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ "-DCMAKE_OSX_ARCHITECTURES=x86_64" ];

    # The launcher executes kyty_emulator and kyty_updater from its own directory,
    # so keep the upstream flat layout instead of installing into bin/.
    postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
      install -Dm755 launcher/kyty_updater $out/kyty_updater
    '';

    postFixup =
      lib.optionalString stdenv.hostPlatform.isLinux ''
        wrapQtApp $out/kyty_launcher
        patchelf --add-rpath ${
          lib.makeLibraryPath [
            vulkan-loader
            libGL
          ]
        } $out/kyty_emulator

        mkdir -p $out/bin
        ln -s ../kyty_launcher $out/bin/kyty_launcher
        ln -s ../kyty_emulator $out/bin/kyty_emulator
      ''
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        # SDL looks for MoltenVK beside the flat emulator and in the bundle's
        # Frameworks directory.
        for dir in $out $out/KytyPS5.app/Contents/Frameworks; do
          install -Dm755 ${moltenvk}/lib/libMoltenVK.dylib "$dir/libMoltenVK.dylib"
          ${lib.getExe ldid} -S "$dir/libMoltenVK.dylib"
        done

        mkdir -p $out/bin
        ln -s ../kyty_emulator $out/bin/kyty_emulator
      '';

    passthru.updateScript = writeShellApplication {
      name = "update-kytyps5";
      runtimeInputs = [
        python3
        nix
        git
        coreutils
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="kytyps5"
        exec ${python3}/bin/python3 ${./update.py} "$@"
      '';
    };

    meta = with lib; {
      description = "PlayStation 5 translation layer";
      homepage = "https://github.com/KytyPS5/KytyPS5";
      downloadPage = "https://github.com/KytyPS5/KytyPS5/releases";
      license = licenses.gpl2Only;
      mainProgram = if stdenv.hostPlatform.isDarwin then "kyty_emulator" else "kyty_launcher";
      platforms = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
      sourceProvenance = [ sourceTypes.fromSource ];
    };
  }
