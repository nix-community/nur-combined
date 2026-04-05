{
  assimp,
  copyDesktopItems,
  desktopToDarwinBundle,
  fetchFromGitHub,
  fetchzip,
  ffmpeg,
  freetype,
  fribidi,
  glew,
  harfbuzz,
  lib,
  libGL,
  libGLU,
  libjpeg,
  libpng,
  makeDesktopItem,
  makeBinaryWrapper,
  openssl,
  pkg-config,
  python312,
  replaceVars,
  SDL2,
  SDL2_image,
  stdenv,
  versionCheckHook,
  zenity,
  zlib,

  # set this to true if you want to use this package to develop and distribute games
  # set this to false if you just want to use this package as a runtime to play games
  withDistributedLibs ? false,
  # set this to true if you additionally want to distribute games for aarch64-linux
  # this implies withDistributedLibs = true because it also includes the libraries for other platforms
  withAarch64LinuxDistributedLibs ?
    withDistributedLibs && stdenv.targetPlatform.isAarch64 && stdenv.targetPlatform.isLinux,
  # notice that you still cannot distribute for non-desktop platforms because they require downloading additional files
}:

# technically we can support cross-compilation by first compiling a renpy for the build platform besides a renpy for the host platform
# and we can use the former to compile the rpy{,m} files but install the latter to $out
# but let's not bother
assert lib.assertMsg (
  stdenv.hostPlatform == stdenv.buildPlatform
) "Ren'Py cannot be cross-compiled because it needs to run itself during the build phase.";

let
  pythonBuildTime = python312.withPackages (
    ps: with ps; [
      cython
      setuptools
      pkgconfig

      # the runtime dependencies are also added to compile bundled rpy{,m} files in renpy source tree
      future
      pefile
      requests
      rsa
      six
    ]
  );
  pythonRunTime = python312.withPackages (
    ps: with ps; [
      future
      pefile
      requests
      rsa
      six
    ]
  );

in
stdenv.mkDerivation (finalAttrs: {
  pname = "renpy";
  # unstable version drops dependency on insecure package ecdsa
  version = "8.5.2.26010301-unstable-2026-03-27";

  src = fetchFromGitHub {
    owner = "renpy";
    repo = "renpy";
    rev = "09eb6986ea9e5dbe64c9096ed48a638e593ea0ef";
    hash = "sha256-w7tQbZCH7F0Npu8rD2UADxe/KzsTUdtIhJY6GH4YFAs=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeBinaryWrapper
    pkg-config
    pythonBuildTime
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs = [
    assimp
    ffmpeg
    freetype
    fribidi
    glew
    harfbuzz
    libGL
    libGLU
    libjpeg
    openssl
    SDL2
    SDL2_image
    pythonRunTime
  ];

  enableParallelBuilding = true;

  patches = [
    # do not try to compile renpy files installed in nix store because we already compiled them at build phase
    ./dont-compile-system.patch

    # catch error instead of crashing when trying to write steam_appid.txt to nix store
    # https://github.com/renpy/renpy/pull/6976
    ./steam-preinit-catch.patch

    # fix write_target looking for wrong file locations when launcher creates new project
    # https://github.com/renpy/renpy/pull/6978
    ./new-project-prefix.patch
  ];

  postPatch = ''
    # use nix out path instead of python var `renpy_base` to avoid problems with distributed renpy
    substituteInPlace renpy/script.py --replace-fail "@systemRenpy@" "$out/share/renpy"

    patchShebangs --build setup.py

    # https://github.com/renpy/renpy/blob/8.5.2.26010301/tutorial/game/01director_support.rpy
    cp tutorial/game/tutorial_director.rpy{m,}

    cat > renpy/vc_version.py << EOF
    branch = 'master'
    version = '${finalAttrs.passthru.appver}'
    official = False
    nightly = False
    # Look at https://renpy.org/latest.html for what to put.
    version_name = "In Good Health"
    EOF
  '';

  buildPhase = ''
    runHook preBuild

    ./setup.py build_ext --inplace -j $NIX_BUILD_CORES

    # so that these files won't need to be compiled on the host platform
    python -m compileall renpy -q -d renpy -f

    # compile bundled rpy{,m} files so that they don't have to be compiled when used on the host platform
    python renpy.py gui compile
    python renpy.py tutorial compile
    python renpy.py the_question compile

    # there is no single command to compile all rpym files, so apply a temporary patch for doing that
    patch -p1 -i ${./temp-compile-modules.patch}
    python renpy.py . compile
    patch -p1 -R -i ${./temp-compile-modules.patch}

    # these are populated when compiling but should not be there
    rm -r {tutorial,the_question}/game/saves

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ./setup.py install_lib -d $out/share/renpy
    cp -ar sdk-fonts gui launcher renpy the_question tutorial renpy.py $out/share/renpy

    # add zenity for file dialogs (https://github.com/renpy/renpy/blob/8.5.2.26010301/src/tinyfiledialogs/tinyfiledialogs.c#L188)
    makeWrapper ${lib.getExe pythonRunTime} $out/bin/renpy \
      --add-flags "$out/share/renpy/renpy.py" \
      --prefix PATH : "${lib.makeBinPath [ zenity ]}"

    # most commands (such as `distribute`) are commands of the launcher but not renpy itself
    makeWrapper $out/bin/renpy $out/bin/renpy-launcher --add-flags "$out/share/renpy/launcher"

    mkdir -p $out/share/icons/hicolor/{256x256,32x32}/apps
    ln -s $out/share/renpy/launcher/game/images/window-icon.png $out/share/icons/hicolor/256x256/apps/renpy.png
    ln -s $out/share/renpy/launcher/game/images/logo32.png $out/share/icons/hicolor/32x32/apps/renpy.png

    ${
      # have to use cp instead of symlinkJoin because renpy resolves symlinks to find its base dir
      if withAarch64LinuxDistributedLibs then
        "cp -ar ${finalAttrs.passthru.binSrcArm}/{update,lib} $out/share/renpy"
      else if withDistributedLibs then
        "cp -ar ${finalAttrs.passthru.binSrc}/{update,lib} $out/share/renpy"
      else
        ""
    }

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "renpy";
      desktopName = "Ren'Py";
      comment = finalAttrs.meta.description;
      exec = "renpy-launcher %U";
      icon = "renpy";
      categories = [ "Development" ];
    })
  ];

  # keep the file redistributable
  dontStrip = true;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = false; # set to true when the version is not unstable

  passthru = {
    appver = lib.head (builtins.match "([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+).*" finalAttrs.version);
    semver = lib.head (builtins.match "([0-9]+\\.[0-9]+\\.[0-9]+).*" finalAttrs.version);

    binSrc = fetchzip {
      url = "https://www.renpy.org/dl/${finalAttrs.passthru.semver}/renpy-${finalAttrs.passthru.semver}-sdk.tar.bz2";
      hash = "sha256-wF6Z/lA8CyaCEZg1IqpZ4mG8CF8JgNHBf5KjKIOoKVI=";
    };

    binSrcArm = fetchzip {
      url = "https://www.renpy.org/dl/${finalAttrs.passthru.semver}/renpy-${finalAttrs.passthru.semver}-sdkarm.tar.bz2";
      hash = "sha256-DKXghs1XIRrtAGTifMx+7XAbxiqH7qYQiaKhBaO7PBA=";
    };
  };

  meta = {
    description = "Visual Novel Engine";
    mainProgram = "renpy";
    homepage = "https://renpy.org/";
    changelog = "https://renpy.org/doc/html/changelog.html";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [
      shadowrz
      ulysseszhan
    ];
    sourceProvenance =
      with lib.sourceTypes;
      [ fromSource ]
      ++ lib.optional (withDistributedLibs || withAarch64LinuxDistributedLibs) binaryNativeCode;
  };
})
