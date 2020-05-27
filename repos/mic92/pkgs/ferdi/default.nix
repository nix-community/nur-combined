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
}:
let
  version = "5.5.1-nightly.15";
in
stdenv.mkDerivation {
  pname = "ferdi";
  inherit version;
  src = fetchurl {
    url = "https://github.com/getferdi/nightlies/releases/download/v${version}/ferdi_${version}_amd64.deb";
    sha256 = "1m9xh24p3dz7krv65w06n4iy856c9c2klwb5ma1nqfqhd9czc3sb";
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

  runtimeDependencies = [ systemd.lib libnotify ];

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
