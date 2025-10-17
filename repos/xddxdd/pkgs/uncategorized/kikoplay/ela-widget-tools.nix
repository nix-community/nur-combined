{
  sources,
  lib,
  stdenv,
  cmake,
  qt6,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.ela-widget-tools) pname version src;

  patches = [ ./ela-widget-tools-fix-install-path.patch ];

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  postInstall = ''
    cp -r $out/ElaWidgetTools/* $out/
    rm -rf $out/ElaWidgetTools
  '';

  meta = {
    mainProgram = "ElaWidgetToolsExample";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Fluent-UI For QT-Widget";
    homepage = "https://github.com/Liniyous/ElaWidgetTools";
    license = lib.licenses.mit;
  };
})
