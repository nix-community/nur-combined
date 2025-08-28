{
  stdenv,
  wpsoffice-cn,
  makeWrapper,
}:
stdenv.mkDerivation {
  name = "wpsoffice-cn-fcitx";
  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    ln -s ${wpsoffice-cn}/share/* -t $out/share
    rm $out/share/applications
    for desktop in $out/share/applications/*;do
      substituteInPlace $desktop \
        --replace-fail ${wpsoffice-cn}/bin $out/bin
    done

    mkdir -p $out/bin
    ln -s ${wpsoffice-cn}/bin/* -t $out/bin
    for exe in $out/bin/*;do
      wrapProgram $exe \
        --prefix XMODIFIERS : @im=fcitx\
        --prefix GTK_IM_MODULE : fcitx\
        --prefix QT_IM_MODULE : fcitx\
        --prefix SDL_IM_MODULE : fcitx\
        --prefix GLFW_IM_MODULE : ibus
    done

    runHook postInstall
  '';
  meta = wpsoffice-cn.meta // {
    description = "WPS Office CN wrapper with Fcitx support";
    mainProgram = "wps";
  };
}
