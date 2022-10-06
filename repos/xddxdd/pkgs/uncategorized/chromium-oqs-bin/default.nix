{ stdenvNoCC
, lib
, sources
, makeWrapper
, steam
, ...
} @ args:

stdenvNoCC.mkDerivation rec {
  pname = "chromium-oqs-bin";
  inherit (sources.chromium-oqs-bin) version src;

  nativeBuildInputs = [ makeWrapper ];
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/opt $out/share/applications
    tar xf $src -C $out/opt

    makeWrapper ${steam.run}/bin/steam-run $out/bin/chromium \
      --argv0 "chrome" \
      --add-flags "$out/opt/chrome"

    cp ${./chromium-oqs.desktop} $out/share/applications/chromium-oqs.desktop
    cp -r ${./icons} $out/share/icons
  '';

  meta = with lib; {
    description = "Chromium with Open Quantum Safe patches";
    homepage = "https://github.com/open-quantum-safe/oqs-demos";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
