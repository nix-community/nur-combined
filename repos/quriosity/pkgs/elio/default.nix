{lib
, stdenv
, fetchurl
, makeDesktopItem
, makeWrapper
, autoPatchelfHook
, nix-update-script
}:

let
  pname = "elio";
  version = "1.12.0";

  src = fetchurl {
    url = "https://github.com/elio-fm/elio/releases/download/v${version}/elio-${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-QLcp3MqW1P5uW8nh2njA2G+Fz3aIFrxx/rBT2jYeQPg=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [
    stdenv.cc.cc.lib
  ];
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/elio
    cp -r ./* $out/opt/elio

    makeWrapper $out/opt/elio/elio $out/bin/elio

    install -m 444 -D $out/opt/elio/packaging/linux/elio.desktop $out/share/applications/${pname}.desktop
    install -m 444 -D $out/opt/elio/packaging/linux/icons/hicolor/256x256/apps/elio.png $out/share/icons/hicolor/256x256/apps/${pname}.png

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Snappy, batteries-included terminal file manager with rich previews, inline images, bulk actions, and trash support";
    homepage = "https://elio-fm.github.io/";
    license = licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "elio";
  };
}
