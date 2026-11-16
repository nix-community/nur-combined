{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
  pdf2svg,
  texlive,
  typst,
}:

appimageTools.wrapType2 rec {
  pname = "equation-exporter";
  version = "0.1.8";

  src = fetchurl {
    url = "https://github.com/freegoxing/Equation-Exporter/releases/download/v${version}/Equation-Exporter_${version}_linux_amd64.AppImage";
    hash = "sha256-WLC1LtDXWH1DQtQJCNsLxER5QFF0R/O9ETNu0mMfokw=";
  };

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
    cp -r ${appimageTools.extract { inherit pname version src; }}/usr/share $out/
    substituteInPlace $out/share/applications/*.desktop \
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
