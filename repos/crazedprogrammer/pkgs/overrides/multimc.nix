{ stdenv, multimc, xorg, jdk, libpulseaudio, ... }:

let
  libpath = with xorg; stdenv.lib.makeLibraryPath [ libX11 libXext libXcursor libXrandr libXxf86vm libpulseaudio ];
in

multimc.overrideDerivation (old: rec {
  postInstall = ''
    mkdir -p $out/share/{applications,pixmaps}
    cp ../application/resources/multimc/scalable/multimc.svg $out/share/pixmaps
    cp ../application/package/linux/multimc.desktop $out/share/applications
    mv $out/bin/MultiMC $out/bin/multimc
    wrapProgram $out/bin/multimc --add-flags "-d \$HOME/.multimc/" --set GAME_LIBRARY_PATH /run/opengl-driver/lib:${libpath} --prefix PATH : ${jdk}/bin/
  '';
})
