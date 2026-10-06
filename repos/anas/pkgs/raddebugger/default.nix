{ lib
, fetchFromGitHub
, stdenv
, bash
, coreutils
, gnugrep
, gnused
, clang
, makeWrapper
, copyDesktopItems
, makeDesktopItem
, imagemagick
, freetype
, libX11
, libxext
, libxfixes
, libGL
, libglvnd
, pkg-config
, llvm
,
}:

let
  pname = "raddebugger";
  version = "0.9.29-alpha";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "EpicGames";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-IQNicRWKdIamDeQU1RRceRR2QgoUlomQYoeCgepO10w=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    bash
    coreutils
    gnugrep
    gnused
    clang
    pkg-config
    makeWrapper
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [
    freetype
    libX11
    libxext
    libxfixes
    libGL
    libglvnd
    llvm
  ];

  NIX_CFLAGS_COMPILE = "-I${freetype.dev}/include/freetype2";

  patchFlags = [
    "-p1"
    "--binary"
  ];

  postPatch = ''
    substituteInPlace build.sh \
      --replace 'git_hash=$(git describe --always --dirty)' 'git_hash=''${GIT_HASH:-unknown}' \
      --replace 'git_hash_full=$(git rev-parse HEAD)' 'git_hash_full=''${GIT_HASH_FULL:-unknown}'
    substituteInPlace src/third_party/radsort/radsort.h \
      --replace '#define RSFORCEINLINE __attribute__((always_inline))' '#define RSFORCEINLINE'
    chmod +x build.sh
  '';

  buildPhase = ''
    runHook preBuild
    CC=${clang}/bin/clang AR=${llvm}/bin/llvm-ar bash ./build.sh clang release raddbg
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    install -Dm755 build/raddbg "$out/bin/raddbg"

    mkdir -p "$out/share/icons/hicolor/256x256/apps"
    magick 'data/logo.ico[0]' \
      -resize 256x256 \
      "$out/share/icons/hicolor/256x256/apps/raddbg.png"

    wrapProgram "$out/bin/raddbg" \
      --prefix PATH : ${lib.makeBinPath [ llvm ]} \
      --set ASAN_SYMBOLIZER_PATH "${llvm}/bin/llvm-symbolizer"

    runHook postInstall
  '';

  desktopItems = lib.optional stdenv.hostPlatform.isLinux (makeDesktopItem {
    name = "raddbg";
    desktopName = "The RAD Debugger";
    exec = "raddbg %f";
    icon = "raddbg";
    startupWMClass = "RADDBG";
    genericName = "Debugger";

    keywords = [
      "debugger"
      "debug"
      "development"
    ];

    categories = [
      "Development"
      "Debugger"
    ];

    mimeTypes = [
      "application/x-executable"
      "application/x-pie-executable"
    ];
  });
  meta = {
    description = "A native, user-mode, multi-process, graphical debugger.";
    homepage = "https://github.com/EpicGames/raddebugger";
    license = lib.licenses.mit;
    mainProgram = "raddbg";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.linux;
  };
}
