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
    cp -r ${wpsoffice-cn}/share/applications -t $out/share
    for desktop in $out/share/applications/*;do
      substituteInPlace $desktop \
        --replace-fail ${wpsoffice-cn}/bin $out/bin
    done

    rm $out/share/templates
    cp -r ${wpsoffice-cn}/share/templates -t $out/share
    for desktop in $out/share/templates/*;do
      substituteInPlace $desktop \
        --replace-warn wps文字文档 WPS文字文档 \
        --replace-warn wps演示文档 WPS演示文稿 \
        --replace-warn wps表格文档 WPS表格工作表 \
        --replace-fail URL=.source URL=${wpsoffice-cn}/opt/kingsoft/wps-office/templates
    done

    mkdir -p $out/bin
    ln -s ${wpsoffice-cn}/bin/* -t $out/bin
    for exe in $out/bin/*;do
      wrapProgram $exe \
        --prefix XMODIFIERS : @im=fcitx\
        --prefix GTK_IM_MODULE : fcitx\
        --prefix QT_IM_MODULE : fcitx
    done
  '';
  meta = wpsoffice-cn.meta // {
    description = "WPS Office CN wrapper with Fcitx support";
    mainProgram = "wps";
  };
}
