{
  assimp,
  copyDesktopItems,
  desktopToDarwinBundle,
  fetchFromGitHub,
  fetchzip,
  ffmpeg_4,
  freetype,
  fribidi,
  glew,
  glibcLocales,
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
  python2,
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
  pythonBuildTime = python2.withPackages (
    ps: with ps; [
      cython
      setuptools

      # the runtime dependencies are also added to compile bundled rpy{,m} files in renpy source tree
      ecdsa
      future
      pefile
      pygame-sdl2
      requests
      six
      typing
    ]
  );
  pythonRunTime = python2.withPackages (
    ps: with ps; [
      ecdsa
      future
      pefile
      pygame-sdl2
      requests
      six
      typing
    ]
  );

in
stdenv.mkDerivation (finalAttrs: {
  pname = "renpy";
  version = "7.8.7.25031702";

  src = fetchFromGitHub {
    owner = "renpy";
    repo = "renpy";
    tag = finalAttrs.version;
    hash = "sha256-QY6MMiagPVV+pCDM0FRD++r2fY3tD8qWmHj7fJKIxUQ=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    copyDesktopItems
    makeBinaryWrapper
    pythonBuildTime
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

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

    # compatibility patches for old games
    # https://github.com/renpy/renpy/pull/6986
    # https://github.com/renpy/renpy/pull/6987
    # https://github.com/renpy/renpy/pull/6989
    ./revert-breaking.patch
  ];

  postPatch = ''
    # use nix out path instead of python var `renpy_base` to avoid problems with distributed renpy
    substituteInPlace renpy/script.py --replace-fail "@systemRenpy@" "$out/share/renpy"

    # optional dependencies are actually required
    substituteInPlace module/setuplib.py \
      --replace-fail "def include(header, directory=None, optional=True):" "def include(header, directory=None, optional=False):"

    # enable parallel compilation of cythonized c files to greatly speed up the build
    cat ${./parallel_setup.py} >> module/setuplib.py

    patchShebangs --build module/setup.py

    # https://github.com/renpy/renpy/blob/7.8.7.25031702/tutorial/game/01director_support.rpy
    cp tutorial/game/tutorial_director.rpy{m,}

    cat > renpy/vc_version.py << EOF
    branch = 'fix'
    version = '${finalAttrs.passthru.appver}'
    official = False
    nightly = False
    # Look at https://renpy.org/latest.html for what to put.
    version_name = "Straight on Till Morning"
    EOF
  '';

  env = {
    # otherwise io.open will read files as ascii and fail to interpret BOM correctly
    # this is usually not a problem at run time because tne user env probably has locale set to something utf-8
    LC_ALL = "en_US.UTF-8";

    # must include both lib and include paths
    # see module/setup{,lib}.py for how these are used
    # note that we still need to include the dependencies in buildInputs
    # because setup.py does not tell the C compiler the headers and libs it found
    RENPY_DEPS_INSTALL = lib.concatMapStringsSep "::" (path: "${path}") [
      ffmpeg_4.lib
      ffmpeg_4.dev
      freetype
      freetype.dev
      fribidi
      glew
      glew.dev
      harfbuzz
      harfbuzz.dev
      libpng
      libpng.dev
      python2.pkgs.pygame-sdl2
      SDL2
      SDL2.dev
      zlib
      zlib.dev
    ];
  };

  buildInputs = [
    ffmpeg_4
    freetype
    fribidi
    glew
    glibcLocales # otherwise LC_ALL does not take effect
    harfbuzz
    libGL
    libGLU
    libpng
    zlib
    pythonRunTime
  ];

  buildPhase = ''
    runHook preBuild

    # cannot use -j $NIX_BUILD_CORES here because distutils does not recognize the option
    # instead use a monkey patch at parallel_setup.py
    module/setup.py build_ext

    # instead of having --inplace option for build_ext, copy them here manually instead
    # because --inplace places them in the module dir mistakenly
    cp -r "$(find module/build -maxdepth 1 -type d -name 'lib.*' -print -quit)"/* .

    # compile bundled rpy{,m} files so that they don't have to be compiled when used on the host platform
    python renpy.py gui compile
    python renpy.py tutorial compile
    python renpy.py the_question compile

    # there is no single command to compile all rpym files, so apply a temporary patch for doing that
    patch -p1 -i ${./temp-compile-modules.patch}
    python renpy.py . compile
    patch -p1 -R -i ${./temp-compile-modules.patch}

    # so that these files won't need to be compiled on the host platform
    # need to run this after the last command because the files patched by ./temp-compile-modules.patch are mistakenly compiled
    python -m compileall renpy -q -d renpy -f

    # these are populated when compiling but should not be there
    rm -r {tutorial,the_question}/game/saves

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    module/setup.py install_lib -d $out/share/renpy
    cp -ar sdk-fonts gui launcher renpy the_question tutorial renpy.py $out/share/renpy

    # add zenity for file dialogs (https://github.com/renpy/renpy/blob/7.8.7.25031702/module/tinyfiledialogs/tinyfiledialogs.c#L172)
    makeWrapper ${lib.getExe pythonRunTime} $out/bin/renpy \
      --prefix PATH : "${lib.makeBinPath [ zenity ]}" \
      --add-flags "$out/share/renpy/renpy.py"

    # most commands (such as `distribute`) are commands of the launcher but not renpy itself
    makeWrapper $out/bin/renpy $out/bin/renpy-launcher \
      --add-flags "$out/share/renpy/launcher"

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
  doInstallCheck = true;

  disallowedReferences = [ glibcLocales ];

  passthru = {
    appver = lib.head (builtins.match "([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+).*" finalAttrs.version);
    semver = lib.head (builtins.match "([0-9]+\\.[0-9]+\\.[0-9]+).*" finalAttrs.version);

    binSrc = fetchzip {
      url = "https://www.renpy.org/dl/${finalAttrs.passthru.semver}/renpy-${finalAttrs.passthru.semver}-sdk.tar.bz2";
      hash = "sha256-+rEsQGp/A31q1P2VEVtPZHlJgnyPvGk3iaGYDx2A/n4=";
    };

    binSrcArm = fetchzip {
      url = "https://www.renpy.org/dl/${finalAttrs.passthru.semver}/renpy-${finalAttrs.passthru.semver}-sdkarm.tar.bz2";
      hash = "sha256-yRSUM+CAx+EDsWSQzZc1g6YGTLCm3b6/ejlFWpZy7ck=";
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Visual Novel Engine (last major version that supports Python 2)";
    mainProgram = "renpy";
    homepage = "https://renpy.org/";
    changelog = "https://renpy.org/doc/html/changelog.html";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    sourceProvenance =
      with lib.sourceTypes;
      [ fromSource ]
      ++ lib.optional (withDistributedLibs || withAarch64LinuxDistributedLibs) binaryNativeCode;
  };
})
