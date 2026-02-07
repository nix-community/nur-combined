{
  lib,
  stdenv,
  fetchFromGitHub,

  coreutils,
  cmake,
  ninja,
  pkg-config,
  wayland-scanner,

  dbus,
  freetype,
  glfw,
  onetbb,

  md4c,
  pugixml,
  curl,
  zstd,
  nlohmann_json,
  nativefiledialog-extended,
  html-tidy,

  withWayland ? stdenv.hostPlatform.isLinux,
  libglvnd,
  libxkbcommon,
  wayland,
  wayland-protocols,
  libffi,
}:

let
  version = "0.13.1";

  cpmSrcs = [
    (fetchFromGitHub {
      name = "ImGui";
      owner = "ocornut";
      repo = "imgui";
      rev = "v1.92.5-docking";
      hash = "sha256-/jVT7+874LCeSF/pdNVTFoSOfRisSqxCJnt5/SGCXPQ=";
    })
    # Use nixpkgs source but let CPM build with tracy's options (NFD_PORTAL)
    (nativefiledialog-extended.src // { name = "nfd"; })
    (fetchFromGitHub {
      name = "PPQSort";
      owner = "GabTux";
      repo = "PPQSort";
      rev = "v1.0.6";
      hash = "sha256-HgM+p2QGd9C8A8l/VaEB+cLFDrY2HU6mmXyTNh7xd0A=";
    })
    # Transitive from PPQSort
    (fetchFromGitHub {
      name = "PackageProject.cmake";
      owner = "TheLartians";
      repo = "PackageProject.cmake";
      rev = "v1.11.1";
      hash = "sha256-E7WZSYDlss5bidbiWL1uX41Oh6JxBRtfhYsFU19kzIw=";
    })
    (fetchFromGitHub {
      name = "capstone";
      owner = "capstone-engine";
      repo = "capstone";
      rev = "6.0.0-Alpha5";
      hash = "sha256-18PTj4hvBw8RTgzaFGeaDbBfkxmotxSoGtprIjcEuVg=";
    })
    (fetchFromGitHub {
      name = "base64";
      owner = "aklomp";
      repo = "base64";
      rev = "v0.5.2";
      hash = "sha256-dIaNfQ/znpAdg0/vhVNTfoaG7c8eFrdDTI0QDHcghXU=";
    })
    (fetchFromGitHub {
      name = "usearch";
      owner = "unum-cloud";
      repo = "usearch";
      rev = "v2.21.3";
      fetchSubmodules = true;
      hash = "sha256-7IylunAkVNceKSXzCkcpp/kAsI3XoqniHe10u3teUVA=";
    })
  ];
in
stdenv.mkDerivation {
  pname = "tracy";
  inherit version;

  src = fetchFromGitHub {
    name = "tracy";
    owner = "wolfpld";
    repo = "tracy";
    rev = "v${version}";
    hash = "sha256-D4aQ5kSfWH9qEUaithR0W/E5pN5on0n9YoBHeMggMSE=";
  };

  postUnpack = lib.strings.concatLines (
    lib.lists.forEach cpmSrcs (
      s:
      ''
        cp -R ${s.out} ${s.name}
        chmod -R u+w ${s.name}
        appendToVar cmakeFlags -DCPM_${s.name}_SOURCE=$(pwd)/${s.name}
      ''
      + lib.optionalString (s.name == "PPQSort") ''
        cp ./tracy/cmake/CPM.cmake PPQSort/cmake/CPM.cmake
      ''
    )
  );

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wayland-scanner ]
  ++ lib.optionals stdenv.cc.isClang [ stdenv.cc.cc.libllvm ];

  buildInputs = [
    freetype
    onetbb
    md4c
    pugixml
    curl
    zstd
    nlohmann_json
    html-tidy
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ dbus ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && withWayland) [
    libglvnd
    libxkbcommon
    wayland
    wayland-protocols
    libffi
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin || (stdenv.hostPlatform.isLinux && !withWayland)) [
    glfw
  ];

  cmakeFlags = [
    (lib.cmakeBool "DOWNLOAD_CAPSTONE" false)
    (lib.cmakeBool "TRACY_STATIC" false)
    (lib.cmakeBool "CPM_LOCAL_PACKAGES_ONLY" true)
    (lib.cmakeBool "CPM_FIND_DEBUG_MODE" true)
    (lib.cmakeFeature "CMAKE_MODULE_PATH" "${./cmake}")
  ]
  ++ lib.optional (stdenv.hostPlatform.isLinux && !withWayland) (lib.cmakeBool "LEGACY" true)
  ++ lib.optional (stdenv.hostPlatform.isLinux && withWayland) (
    lib.cmakeFeature "CPM_wayland-protocols_SOURCE" "${wayland-protocols}/share/wayland-protocols"
  );

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isLinux "-ltbb";

  dontUseCmakeBuildDir = true;

  postConfigure = ''
    cmake -B profiler/build -S profiler $cmakeFlags

    appendToVar cmakeFlags -DPATCH_EXECUTABLE=${coreutils}/bin/true

    cmake -B capture/build -S capture $cmakeFlags
    cmake -B csvexport/build -S csvexport $cmakeFlags
    cmake -B import/build -S import $cmakeFlags
    cmake -B update/build -S update $cmakeFlags
  '';

  postBuild = ''
    ninja -C capture/build
    ninja -C csvexport/build
    ninja -C import/build
    ninja -C profiler/build
    ninja -C update/build
  '';

  postInstall = ''
    install -D -m 0555 capture/build/tracy-capture -t $out/bin
    install -D -m 0555 csvexport/build/tracy-csvexport $out/bin
    install -D -m 0555 import/build/{tracy-import-chrome,tracy-import-fuchsia} -t $out/bin
    install -D -m 0555 profiler/build/tracy-profiler $out/bin/tracy
    install -D -m 0555 update/build/tracy-update -t $out/bin
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace extra/desktop/tracy.desktop \
      --replace-fail Exec=/usr/bin/tracy Exec=tracy

    install -D -m 0444 extra/desktop/application-tracy.xml $out/share/mime/packages/application-tracy.xml
    install -D -m 0444 extra/desktop/tracy.desktop $out/share/applications/tracy.desktop
    install -D -m 0444 icon/application-tracy.svg $out/share/icons/hicolor/scalable/apps/application-tracy.svg
    install -D -m 0444 icon/icon.png $out/share/icons/hicolor/256x256/apps/tracy.png
    install -D -m 0444 icon/icon.svg $out/share/icons/hicolor/scalable/apps/tracy.svg
  '';

  meta = {
    description = "Real time, nanosecond resolution, remote telemetry frame profiler for games and other applications";
    homepage = "https://github.com/wolfpld/tracy";
    license = lib.licenses.bsd3;
    mainProgram = "tracy";
    platforms = lib.platforms.linux ++ lib.optionals (!withWayland) lib.platforms.darwin;
  };
}
