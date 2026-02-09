{
  appimageTools,
  makeWrapper,

  meta,
  src,
  pname,
  version,
}:
let
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit
    pname
    version
    src
    meta
    ;
  nativeBuildInputs = [ makeWrapper ];
  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/io.github.MCDFsteve.NipaPlay-Reload.desktop -t $out/share/applications
    install -Dm644 ${appimageContents}/io.github.MCDFsteve.NipaPlay-Reload.png -t $out/share/icons/hicolor/512x512/apps

    substituteInPlace $out/share/applications/io.github.MCDFsteve.NipaPlay-Reload.desktop \
      --replace-fail '/opt/nipaplay/NipaPlay' '${pname}'

    wrapProgram $out/bin/${pname} \
      --unset GDK_PIXBUF_MODULE_FILE \
      --unset GIO_EXTRA_MODULES
  '';
  extraPkgs =
    pkgs: with pkgs; [
      keybinder
      mpv-unwrapped
      ffmpeg
      libass
      webkitgtk_4_1
    ];
}
