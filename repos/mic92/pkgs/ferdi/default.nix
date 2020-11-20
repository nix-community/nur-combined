{ stdenv
, fetchurl
, makeWrapper
, wrapGAppsHook
, autoPatchelfHook
, dpkg
, gtk3
, alsaLib
, systemd
, libnotify
, xlibs
, xdg_utils
, nss
, nodePackages
, pulseaudio
}:
let
  version = "5.5.0";
in
stdenv.mkDerivation {
  pname = "ferdi";
  inherit version;
  src = fetchurl {
    url = "https://github.com/getferdi/ferdi/releases/download/v${version}/ferdi_${version}_amd64.deb";
    sha256 = "sha256-czh1PHWsbj3NGwxK9NzxqSfnRJrPCVtxVeVHgi3bREQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook makeWrapper wrapGAppsHook dpkg
    nodePackages.asar
  ];

  buildInputs = [
    gtk3
    xlibs.libXScrnSaver
    xlibs.libXtst
    xlibs.libxkbfile
    alsaLib
    nss
  ];

  runtimeDependencies = [
    (stdenv.lib.getLib systemd)
    libnotify
    pulseaudio
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out/bin
    cp -r opt $out
    ln -s $out/opt/Ferdi/ferdi $out/bin

    asar extract $out/opt/Ferdi/resources/app.asar resources
    autoPatchelf resources
    asar pack resources $out/opt/Ferdi/resources/app.asar

    # provide desktop item and icon
    cp -r usr/share $out
    substituteInPlace $out/share/applications/ferdi.desktop \
      --replace Exec=\"/opt/Ferdi/ferdi\" Exec=ferdi
  '';

  dontWrapGApps = true;

  postFixup = ''
    # ferdi without an account requires libstdc++ at runtime
    wrapProgram $out/opt/Ferdi/ferdi \
      --prefix PATH : ${xdg_utils}/bin \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = with stdenv.lib; {
    description = "A free messaging app that combines chat & messaging services into one application";
    homepage = "https://getferdi.com";
    license = licenses.free;
    maintainers = [ maintainers.mic92 ];
    platforms = [ "x86_64-linux" ];
    hydraPlatforms = [ ];
  };
}
