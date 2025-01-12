{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.helion-bin) pname version src;
  sourceRoot = ".";

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
    makeWrapper
  ];

  buildInputs = with pkgs; [
    glib
    libGL
    libsndfile
    openal
    stdenv.cc.cc.lib
    xorg.libX11
  ];

  buildPhase = ''
    mkdir -p $out/{bin,libexec}
    cp -r * $out/libexec

    makeWrapper $out/libexec/Helion $out/bin/Helion \
      --set DOTNET_ROOT ${pkgs.dotnetCorePackages.dotnet_8.runtime}/share/dotnet

    patchelf $out/libexec/Helion \
      --add-needed libopenal.so.1 \
      --add-needed libGL.so
  '';

  meta = with pkgs.lib; {
    description = "A modern fast paced Doom FPS engine";
    homepage = "https://github.com/Helion-Engine/Helion";
    license = licenses.gpl3Only;
    platforms = ["x86_64-linux"];
  };
}
