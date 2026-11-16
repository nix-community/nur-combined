{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
  pdf2svg,
  texlive,
  typst,
}:

let
  pname = "equation-exporter";
  version = "0.1.8";
  src = fetchurl {
    url = "https://github.com/freegoxing/Equation-Exporter/releases/download/v${version}/Equation-Exporter_${version}_linux_amd64.AppImage";
    hash = "sha256-WLC1LtDXWH1DQtQJCNsLxER5QFF0R/O9ETNu0mMfokw=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ pkgs.libgpg-error ];
  nativeBuildInputs = [ makeWrapper ];
  extraInstallCommands = ''
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        lib.makeBinPath [
          pdf2svg
          (texlive.withPackages (p: [
            p.scheme-basic
            p.standalone
            p.amsmath
            p.amsfonts
            p.mathtools
            p.cancel
            p.extarrows
            p.xcolor
          ]))
          typst
        ]
      }
    install -Dm644 '${appimageContents}/usr/share/applications/Equation Exporter.desktop' \
      "$out/share/applications/Equation Exporter.desktop"
    for size in 32x32 128x128 256x256@2; do
      install -Dm644 '${appimageContents}/usr/share/icons/hicolor/'"$size"'/apps/equation-exporter-tauri.png' \
        "$out/share/icons/hicolor/$size/apps/equation-exporter-tauri.png"
    done
    substituteInPlace "$out/share/applications/Equation Exporter.desktop" \
      --replace-fail 'Exec=equation-exporter-tauri' 'Exec=${pname}'
  '';

  meta = {
    description = "Desktop equation editor and exporter";
    homepage = "https://github.com/freegoxing/Equation-Exporter";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = pname;
  };
}
