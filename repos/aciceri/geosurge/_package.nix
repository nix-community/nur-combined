{
  lib,
  appimageTools,
  fetchurl,
  nix-update,
  writeShellScript,
}:
let
  pname = "geosurge";
  version = "1.0.7";

  src = fetchurl {
    url = "https://github.com/geosurge-ai/geoSurge-releases/releases/download/v${version}/geosurge-${version}-x86_64.AppImage";
    hash = "sha256-bgGis5wbO7sY93PMXU1Pkf5mpRsPqIs4M6mgQzQSGss=";
  };

  # Only used to lift the desktop entry and the icon out of the image, the
  # runtime still executes the AppImage itself inside the FHS environment.
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Electron dlopens libnotify at runtime for desktop notifications; the copy
  # bundled in the AppImage is a GTK2-era build, so the FHS one wins.
  extraPkgs = pkgs: [ pkgs.libnotify ];

  extraInstallCommands = ''
    install -Dm444 ${contents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail "Exec=AppRun" "Exec=${pname}"
    cp -r ${contents}/usr/share/icons $out/share
  '';

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake ${pname}";

  meta = {
    description = "geoSurge menubar app and daemon for BYO-subscription AI brand-visibility runs";
    homepage = "https://github.com/geosurge-ai/geoSurge-releases";
    license = lib.licenses.unfree;
    mainProgram = pname;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = [ "x86_64-linux" ];
  };
}
