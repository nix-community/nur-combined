{
  lib,
  pkgs,
  stdenv,
  ...
}:
stdenv.mkDerivation rec {
  pname = "gdsdecomp";
  version = "v2.6.4";

  # gdre_tools.pck, gdre_tools.x86_64, libGodotMonoDecompNativeAOT.so
  src = pkgs.fetchzip {
    url = "https://github.com/GDRETools/gdsdecomp/releases/download/${version}/GDRE_tools-${version}-linux.zip";
    hash = "sha256-aaPDbDyT+oPNXpjIskxf8dR32oZp21V7sAAbW+tQAyE=";
    stripRoot = false;
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/gdre_tools
    mv gdre_tools.x86_64 $out/libexec/gdre_tools/gdre_tools
    mv gdre_tools.pck $out/libexec/gdre_tools/gdre_tools.pck
    mv libGodotMonoDecompNativeAOT.so $out/libexec/gdre_tools/
    chmod a+x $out/libexec/gdre_tools/gdre_tools

    makeWrapper $out/libexec/gdre_tools/gdre_tools $out/bin/gdre_tools \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"

    runHook postInstall
  '';

  # Godot dlopens its windowing, audio and graphics libraries at runtime, so they
  # have to be handed over through LD_LIBRARY_PATH rather than autoPatchelf
  runtimeLibs =
    with pkgs;
    with xorg;
    [
      alsa-lib
      dbus
      fontconfig
      libdecor
      libGL
      libpulseaudio
      libX11
      libXcursor
      libXext
      libXi
      libXinerama
      libXrandr
      libXrender
      libxkbcommon
      speechd-minimal
      systemdLibs
      vulkan-loader
      wayland
    ];

  meta = {
    description = "Godot reverse engineering tools (GDRE Tools)";
    homepage = "https://github.com/GDRETools/gdsdecomp";
    license = lib.licenses.mit;
    mainProgram = "gdre_tools";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
