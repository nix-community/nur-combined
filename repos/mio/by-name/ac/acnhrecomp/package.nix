{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  sdl3,
  zlib,
  makeWrapper,
  python3,
  curl,
  git,
  gnutar,
  gzip,
  zstd,
  unzip,
  which,
  nix-update-script,
}:

let
  # The launcher downloads Dear ImGui at configure time when NX_IMGUI_DIR is
  # unset; point it at a pinned copy instead so the build stays offline.
  imgui = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    tag = "v1.91.9";
    hash = "sha256-a9qmk7sN/ZZul5VvDoa11frblYDaZLcvfs/WQLZ2KJY=";
  };

  # macOS configures the native Metal backend, whose SPIRV-Cross is fetched at
  # configure time. Pin it and point FetchContent at the local checkout.
  spirv-cross = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Cross";
    tag = "vulkan-sdk-1.4.309.0";
    hash = "sha256-ctSMpvw9Wx/IiF0jOGkLmNUAQk855Hf9RwTWYz7mk+k=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "acnhrecomp";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "Nycolazs";
    repo = "ACNHRecomp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b80NfFeSn1ondnbITLPn4J3IaoJetBZGpP9Tum9lHz8=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    makeWrapper
    python3
    curl
    git
    gnutar
    gzip
    zstd
    unzip
    which
  ];

  buildInputs = [
    sdl3
    zlib
  ];

  # The setup script below the launcher writes its venv and third-party tools
  # into <repo>/private, so point the launcher at a writable copy of the
  # checkout instead of the read-only store path baked in by CMake.
  postPatch = ''
    substituteInPlace launcher/files.cpp \
      --replace-fail \
        'starts.push_back(NX_LAUNCHER_SOURCE_DIR);' \
        'if (const char* override = std::getenv("ACNH_RECOMP_SOURCE_DIR")) starts.push_back(override); starts.push_back(NX_LAUNCHER_SOURCE_DIR);'
  '';

  env.NX_RELEASE_VERSION = "v${finalAttrs.version}";

  cmakeFlags = [
    "-DNX_GAME=acnh"
    "-DNX_IMGUI_DIR=${imgui}"
    "-DFETCHCONTENT_SOURCE_DIR_SPIRV_CROSS=${spirv-cross}"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  # Only the launcher is built: the game's executable needs the user's own
  # recompiled game code, so it cannot be built in a Nix build.
  buildPhase = ''
    runHook preBuild
    cmake --build . --target acnhrecomp_launcher
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # The launcher runs tools/setup_acnh.py from its checkout, so ship the
    # repository tree with it (no game files exist in it).
    mkdir -p "$out/share/acnhrecomp" "$out/libexec"
    cp -R ${finalAttrs.src}/. "$out/share/acnhrecomp/"

    install -Dm755 acnhrecomp_launcher "$out/libexec/acnhrecomp_launcher"
    makeWrapper "$out/libexec/acnhrecomp_launcher" "$out/bin/acnhrecomp" \
      --run '
        state="''${ACNH_RECOMP_STATE:-''${XDG_DATA_HOME:-$HOME/.local/share}/acnhrecomp/src}"
        mkdir -p "$state"
        cp -Rf "${placeholder "out"}/share/acnhrecomp/." "$state"/
        chmod -R u+w "$state"
        export ACNH_RECOMP_SOURCE_DIR="$state"
      ' \
      --prefix PATH : ${
        lib.makeBinPath [
          python3
          curl
          git
          gnutar
          gzip
          zstd
          unzip
          which
          cmake
          ninja
          pkg-config
        ]
      }

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Native PC port of Animal Crossing: New Horizons (launcher)";
    longDescription = ''
      ACNHRecomp is a native recompilation of Animal Crossing: New Horizons.
      This package builds the from-source launcher, which prepares the game
      from the user's own extracted game files; the game's recompiled code is
      not included and cannot be built without those files.
    '';
    homepage = "https://github.com/Nycolazs/ACNHRecomp";
    changelog = "https://github.com/Nycolazs/ACNHRecomp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "acnhrecomp";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    # Building the launcher is self-contained, but running its setup needs the
    # user's game dump and network access.
    hydraPlatforms = [ ];
  };
})
