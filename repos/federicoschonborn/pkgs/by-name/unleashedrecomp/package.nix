{
  lib,
  symlinkJoin,
  clangStdenv,
  fetchFromGitHub,
  requireFile,
  cmake,
  directx-shader-compiler,
  makeWrapper,
  ninja,
  pkg-config,
  vcpkg,
  wrapGAppsHook3,
  # UnleashedRecomp includes its own copy of SDL2.
  SDL2_classic,
  curl,
  vulkan-loader,
  freetype,
  gtk3,
  replaceVarsWith,
  nix-update-script,
}:

let
  directx-shader-compiler' = directx-shader-compiler.overrideAttrs (_: {
    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/lib $dev/include
      mv bin/dxc* $out/bin/
      mv lib/lib*.so* lib/lib*.*dylib $out/lib/
      cp -r $src/include/dxc $dev/include/

      runHook postInstall
    '';
  });

  directx-shader-compiler-libdxildll = symlinkJoin {
    name = "${lib.getName directx-shader-compiler'}-${lib.getVersion directx-shader-compiler'}-libdxildll";
    paths = [
      directx-shader-compiler'
    ];
    postBuild = ''
      ln -s $out/lib/libdxil.so $out/lib/libdxildll.so
    '';
  };
in

clangStdenv.mkDerivation (finalAttrs: {
  pname = "unleashedrecomp";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "hedge-dev";
    repo = "UnleashedRecomp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/QJzueRUkS4qqh58JYNhhNtk3di8UFPFHQ1SfTyZLYo=";
    fetchSubmodules = true;
  };

  defaultXex = requireFile {
    name = "default.xex";
    # TODO: Fill me.
    message = "";
    hash = "sha256-iaUxKCB6XpMUZUfJKzlrl85wUXet0L2dn2NneENHaLg=";
  };

  shaderAr = requireFile {
    name = "shader.ar";
    # TODO: Fill me.
    message = "";
    hash = "sha256-5e/ysO+r1sSv9sVjMpIygQJxUm5P0Kvy3i93MNuLY+U=";
  };

  defaultXexp = requireFile {
    name = "default.xexp";
    # TODO: Fill me.
    message = "";
    hash = "sha256-sSu30I53t18HWPewUyJLcd6ZA1kmcSFP5N0iIJeRGhY=";
  };

  nativeBuildInputs = [
    cmake
    directx-shader-compiler-libdxildll
    makeWrapper
    ninja
    pkg-config
    vcpkg
    wrapGAppsHook3
  ] ++ SDL2_classic.nativeBuildInputs;

  buildInputs = [
    curl
    vulkan-loader
    # Required by bundled msdfgen library
    freetype
    # Required by bundled nativefiledialog library
    gtk3
  ] ++ SDL2_classic.buildInputs;

  directx-dxc-config = replaceVarsWith {
    src = ./directx-dxc-config.cmake;

    replacements = {
      dxc = lib.getExe' directx-shader-compiler' "dxc";
      dxscLib = lib.getLib directx-shader-compiler';
      dxscDev = lib.getDev directx-shader-compiler';
    };

    dir = "cmake";
  };

  cmakeFlags = [
    "-DSDL2MIXER_VORBIS=VORBISFILE"
    "-Ddirectx-dxc_DIR=${finalAttrs.directx-dxc-config}/cmake"
  ];

  postPatch = ''
    substituteInPlace UnleashedRecomp/CMakeLists.txt --replace-fail "file(CHMOD" "# file(CHMOD"
  '';

  preConfigure = ''
    export VCPKG_ROOT="${vcpkg}/share/vcpkg"
    cp ${finalAttrs.defaultXex} UnleashedRecompLib/private/default.xex
    cp ${finalAttrs.shaderAr} UnleashedRecompLib/private/shader.ar
    cp ${finalAttrs.defaultXexp} UnleashedRecompLib/private/default.xexp
  '';

  installPhase = ''
    runHook preInstall

    install -Dm00755 UnleashedRecomp/UnleashedRecomp -t $out/bin
    install -Dm00644 ../UnleashedRecompResources/images/game_icon.png $out/share/icons/hicolor/128x128/apps/io.github.hedge_dev.unleashedrecomp.png
    install -Dm00644 ../flatpak/io.github.hedge_dev.unleashedrecomp.metainfo.xml -t $out/share/metainfo
    install -Dm00644 ../flatpak/io.github.hedge_dev.unleashedrecomp.desktop -t $out/share/applications

    runHook postInstall
  '';

  dontWrapGApps = true;

  postFixup = ''
    wrapProgram $out/bin/UnleashedRecomp \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      "''${gappsWrapperArgs[@]}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "unleashedrecomp";
    description = "An unofficial PC port of the Xbox 360 version of Sonic Unleashed created through the process of static recompilation";
    homepage = "https://github.com/hedge-dev/UnleashedRecomp";
    changelog = "https://github.com/hedge-dev/UnleashedRecomp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
